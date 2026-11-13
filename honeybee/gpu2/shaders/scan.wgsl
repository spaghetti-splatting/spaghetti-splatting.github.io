// Prefix sums of u32 values (P1, P5, the digit counts of P7) and the stable
// compaction of P1. A workgroup scans 256 elements. The block sums of one
// level are the input of the next level, until one block remains. The
// element count of each level comes from the counts buffer, so a GPU count
// sets the size without a read-back.

struct PlanParams {
  source_slot: u32,   // counts slot of the element count n
  level_slot: u32,    // first counts slot of the level sizes
  args_index: u32,    // first u32 of the indirect dispatch arguments
  levels: u32,        // number of levels
};

struct ScanParams {
  size_slot: u32,     // counts slot of the element count of this level
  exclusive: u32,     // 1: level 0 writes the exclusive prefix sum
  has_upper: u32,     // 1: a scanned upper level exists
  pad: u32,
};

struct CompactParams {
  rows: u32,          // flag count N
  pad0: u32,
  pad1: u32,
  pad2: u32,
};

@group(0) @binding(0) var<storage, read> scan_in: array<u32>;
@group(0) @binding(1) var<storage, read_write> scan_out: array<u32>;
@group(0) @binding(2) var<storage, read_write> scan_sums: array<u32>;
@group(0) @binding(3) var<storage, read> scan_counts: array<u32>;
@group(0) @binding(4) var<uniform> scan_params: ScanParams;
@group(0) @binding(5) var<storage, read> scan_upper: array<u32>;

@group(0) @binding(0) var<storage, read_write> plan_counts: array<u32>;
@group(0) @binding(1) var<storage, read_write> plan_args: array<u32>;
@group(0) @binding(2) var<uniform> plan_params: PlanParams;

@group(0) @binding(0) var<storage, read> compact_flags: array<u32>;
@group(0) @binding(1) var<storage, read> compact_offsets: array<u32>;
@group(0) @binding(2) var<storage, read_write> compact_rows: array<u32>;
@group(0) @binding(3) var<storage, read_write> compact_counts: array<u32>;
@group(0) @binding(4) var<uniform> compact_params: CompactParams;

var<workgroup> scan_buffer: array<u32, 512>;

// The 1D or 2D grid of a dispatch of `groups` workgroups.
fn grid_of(groups: u32) -> vec3u {
  if (groups <= 65535u) {
    return vec3u(groups, 1u, 1u);
  }
  return vec3u(32768u, (groups + 32767u) / 32768u, 1u);
}

// One thread writes the size and the dispatch arguments of each level.
@compute @workgroup_size(1)
fn scan_plan() {
  var n = plan_counts[plan_params.source_slot];
  for (var level = 0u; level < plan_params.levels; level = level + 1u) {
    plan_counts[plan_params.level_slot + level] = n;
    let blocks = (n + WORKGROUP_SIZE - 1u) / WORKGROUP_SIZE;
    let grid = grid_of(blocks);
    let base = plan_params.args_index + 3u * level;
    plan_args[base] = grid.x;
    plan_args[base + 1u] = grid.y;
    plan_args[base + 2u] = grid.z;
    n = blocks;
  }
}

// Inclusive scan of one value per thread over the 256 threads
// (Hillis-Steele, two halves of scan_buffer in turn).
fn workgroup_inclusive_scan(lid: u32, value: u32) -> u32 {
  scan_buffer[lid] = value;
  workgroupBarrier();
  var source = 0u;
  for (var offset = 1u; offset < WORKGROUP_SIZE; offset = offset << 1u) {
    let other = WORKGROUP_SIZE - source;
    var sum = scan_buffer[source + lid];
    if (lid >= offset) {
      sum = sum + scan_buffer[source + lid - offset];
    }
    scan_buffer[other + lid] = sum;
    source = other;
    workgroupBarrier();
  }
  return scan_buffer[source + lid];
}

// Level step up: the inclusive scan inside each block, and the block sum.
@compute @workgroup_size(256)
fn scan_up(@builtin(local_invocation_index) lid: u32,
           @builtin(workgroup_id) wid: vec3u,
           @builtin(num_workgroups) nwg: vec3u) {
  let block = linear_group(wid, nwg);
  let n = scan_counts[scan_params.size_slot];
  let blocks = (n + WORKGROUP_SIZE - 1u) / WORKGROUP_SIZE;
  if (block >= blocks) {
    return;
  }
  let i = block * WORKGROUP_SIZE + lid;
  var value = 0u;
  if (i < n) {
    value = scan_in[i];
  }
  let inclusive = workgroup_inclusive_scan(lid, value);
  if (i < n) {
    scan_out[i] = inclusive;
  }
  if (lid == WORKGROUP_SIZE - 1u) {
    scan_sums[block] = inclusive;
  }
}

// Level step down: add the scanned sum of the earlier blocks. Level 0 of
// an exclusive scan then subtracts the element itself.
@compute @workgroup_size(256)
fn scan_down(@builtin(local_invocation_index) lid: u32,
             @builtin(workgroup_id) wid: vec3u,
             @builtin(num_workgroups) nwg: vec3u) {
  let block = linear_group(wid, nwg);
  let n = scan_counts[scan_params.size_slot];
  let i = block * WORKGROUP_SIZE + lid;
  if (i >= n) {
    return;
  }
  var value = scan_out[i];
  if (scan_params.has_upper != 0u && block > 0u) {
    value = value + scan_upper[block - 1u];
  }
  if (scan_params.exclusive != 0u) {
    value = value - scan_in[i];
  }
  scan_out[i] = value;
}

// P1 scatter: compact_offsets holds the exclusive scan of the flags. A kept
// row r goes to position offsets[r], so the kept rows keep their order
// (keep.nonzero()). With no kept row, the list is [0] and K = 1, as
// _prefilter_visible_rows does it.
@compute @workgroup_size(256)
fn compact_scatter(@builtin(local_invocation_index) lid: u32,
                   @builtin(workgroup_id) wid: vec3u,
                   @builtin(num_workgroups) nwg: vec3u) {
  let i = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  let n = compact_params.rows;
  if (i >= n) {
    return;
  }
  let flag = compact_flags[i];
  if (flag != 0u) {
    compact_rows[compact_offsets[i]] = i;
  }
  if (i == n - 1u) {
    let total = compact_offsets[i] + flag;
    if (total == 0u) {
      compact_rows[0] = 0u;
      compact_counts[SLOT_KEPT] = 1u;
    } else {
      compact_counts[SLOT_KEPT] = total;
    }
  }
}
