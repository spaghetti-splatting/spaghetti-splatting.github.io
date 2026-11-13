// The indirect dispatch arguments of one frame, formed on the GPU from the
// GPU counts, and P8, the tile ranges (identifyTileRanges,
// rasterizer_impl.cu). No pass reads a count back to the host.

struct FrameParams {
  kept_args: u32,     // args word of the grid over the K kept rows
  pair_args: u32,     // args word of the grid over the sort workgroups
  capacity: u32,      // pair capacity
  pad: u32,
};

@group(0) @binding(0) var<storage, read_write> frame_counts: array<u32>;
@group(0) @binding(1) var<storage, read_write> frame_args: array<u32>;
@group(0) @binding(2) var<storage, read> frame_offsets: array<u32>;  // inclusive scan of tiles
@group(0) @binding(3) var<uniform> frame_params: FrameParams;

@group(0) @binding(0) var<storage, read> sorted_hi: array<u32>;
@group(0) @binding(1) var<storage, read> range_counts: array<u32>;
@group(0) @binding(2) var<storage, read_write> ranges: array<u32>;   // [tiles, 2]

fn grid_words(groups: u32) -> vec3u {
  if (groups <= 65535u) {
    return vec3u(groups, 1u, 1u);
  }
  return vec3u(32768u, (groups + 32767u) / 32768u, 1u);
}

// After P1: the grid of P2, P3, P4 and P6 over the K kept rows.
@compute @workgroup_size(1)
fn args_after_compaction() {
  let kept = frame_counts[SLOT_KEPT];
  let grid = grid_words((kept + WORKGROUP_SIZE - 1u) / WORKGROUP_SIZE);
  frame_args[frame_params.kept_args] = grid.x;
  frame_args[frame_params.kept_args + 1u] = grid.y;
  frame_args[frame_params.kept_args + 2u] = grid.z;
}

// After P5: the pair count (num_rendered = offsets[K - 1]), its clamp to the
// capacity, and the grid of P7 and P8.
@compute @workgroup_size(1)
fn args_after_scan() {
  let kept = frame_counts[SLOT_KEPT];
  let raw = frame_offsets[kept - 1u];
  let pairs = min(raw, frame_params.capacity);
  let groups = (pairs + WORKGROUP_SIZE - 1u) / WORKGROUP_SIZE;
  frame_counts[SLOT_PAIRS_RAW] = raw;
  frame_counts[SLOT_PAIRS] = pairs;
  frame_counts[SLOT_SORT_GROUPS] = groups;
  frame_counts[SLOT_SORT_COUNTS] = 16u * groups;
  let grid = grid_words(groups);
  frame_args[frame_params.pair_args] = grid.x;
  frame_args[frame_params.pair_args + 1u] = grid.y;
  frame_args[frame_params.pair_args + 2u] = grid.z;
}

// P8: the start and the end of the range of each tile in the sorted list.
@compute @workgroup_size(256)
fn tile_ranges(@builtin(local_invocation_index) lid: u32,
               @builtin(workgroup_id) wid: vec3u,
               @builtin(num_workgroups) nwg: vec3u) {
  let idx = linear_group(wid, nwg) * WORKGROUP_SIZE + lid;
  let count = range_counts[SLOT_PAIRS];
  if (idx >= count) {
    return;
  }
  let current = sorted_hi[idx];
  if (idx == 0u) {
    ranges[2u * current] = 0u;
  } else {
    let previous = sorted_hi[idx - 1u];
    if (current != previous) {
      ranges[2u * previous + 1u] = idx;
      ranges[2u * current] = idx;
    }
  }
  if (idx == count - 1u) {
    ranges[2u * current + 1u] = count;
  }
}
