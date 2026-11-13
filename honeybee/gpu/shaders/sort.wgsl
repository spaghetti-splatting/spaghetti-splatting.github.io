// P7: stable LSD radix sort of the (key_hi, key_lo, value) pairs, the order
// of cub::DeviceRadixSort::SortPairs over the 64-bit key
// (key_hi << 32) | key_lo. One pass sorts one 4-bit digit. A workgroup
// takes 256 keys. sort_count writes the digit counts of each workgroup in
// digit-major order; scan.wgsl forms their exclusive scan; sort_scatter
// moves each key to the scanned offset of its (digit, workgroup) plus its
// rank among the earlier keys of the workgroup with the same digit.

struct SortParams {
  shift: u32,      // bit position of the digit in the key word
  use_hi: u32,     // 1: the digit comes from key_hi, 0: from key_lo
  move_lo: u32,    // 1: move key_lo too (a later pass reads it)
  pad: u32,
};

@group(0) @binding(0) var<storage, read> count_keys: array<u32>;
@group(0) @binding(1) var<storage, read> count_counts: array<u32>;
@group(0) @binding(2) var<storage, read_write> count_digits: array<u32>;
@group(0) @binding(3) var<uniform> count_params: SortParams;

@group(0) @binding(0) var<storage, read> in_hi: array<u32>;
@group(0) @binding(1) var<storage, read> in_lo: array<u32>;
@group(0) @binding(2) var<storage, read> in_value: array<u32>;
@group(0) @binding(3) var<storage, read_write> out_hi: array<u32>;
@group(0) @binding(4) var<storage, read_write> out_lo: array<u32>;
@group(0) @binding(5) var<storage, read_write> out_value: array<u32>;
@group(0) @binding(6) var<storage, read> digit_offsets: array<u32>;
@group(0) @binding(7) var<storage, read> scatter_counts: array<u32>;
@group(0) @binding(8) var<uniform> scatter_params: SortParams;

var<workgroup> digit_histogram: array<atomic<u32>, 16>;
// Two halves of 256 threads x 2 vec4 words: the 16 one-hot digit flags of a
// thread in 16-bit lanes (digit d in word d / 2, lane d % 2).
var<workgroup> rank_buffer: array<vec4u, 1024>;

@compute @workgroup_size(256)
fn sort_count(@builtin(local_invocation_index) lid: u32,
              @builtin(workgroup_id) wid: vec3u,
              @builtin(num_workgroups) nwg: vec3u) {
  let block = linear_group(wid, nwg);
  let blocks = count_counts[SLOT_SORT_GROUPS];
  if (block >= blocks) {
    return;
  }
  let n = count_counts[SLOT_PAIRS];
  if (lid < 16u) {
    atomicStore(&digit_histogram[lid], 0u);
  }
  workgroupBarrier();
  let i = block * WORKGROUP_SIZE + lid;
  if (i < n) {
    let digit = (count_keys[i] >> count_params.shift) & 15u;
    atomicAdd(&digit_histogram[digit], 1u);
  }
  workgroupBarrier();
  if (lid < 16u) {
    count_digits[lid * blocks + block] = atomicLoad(&digit_histogram[lid]);
  }
}

@compute @workgroup_size(256)
fn sort_scatter(@builtin(local_invocation_index) lid: u32,
                @builtin(workgroup_id) wid: vec3u,
                @builtin(num_workgroups) nwg: vec3u) {
  let block = linear_group(wid, nwg);
  let blocks = scatter_counts[SLOT_SORT_GROUPS];
  if (block >= blocks) {
    return;
  }
  let n = scatter_counts[SLOT_PAIRS];
  let i = block * WORKGROUP_SIZE + lid;
  let valid = i < n;
  var hi = 0u;
  var lo = 0u;
  var value = 0u;
  var digit = 0u;
  var low_flags = vec4u(0u);
  var high_flags = vec4u(0u);
  if (valid) {
    hi = in_hi[i];
    value = in_value[i];
    if (scatter_params.move_lo != 0u || scatter_params.use_hi == 0u) {
      lo = in_lo[i];
    }
    let key = select(lo, hi, scatter_params.use_hi != 0u);
    digit = (key >> scatter_params.shift) & 15u;
    let word = digit >> 1u;
    let lane_bit = 1u << ((digit & 1u) * 16u);
    if (word < 4u) {
      low_flags[word] = lane_bit;
    } else {
      high_flags[word - 4u] = lane_bit;
    }
  }
  // Inclusive scan of the 16 one-hot flags over the 256 threads. A lane
  // holds at most 256, so a lane never carries into the next lane.
  rank_buffer[2u * lid] = low_flags;
  rank_buffer[2u * lid + 1u] = high_flags;
  workgroupBarrier();
  var source = 0u;
  for (var offset = 1u; offset < WORKGROUP_SIZE; offset = offset << 1u) {
    let other = 512u - source;
    var low_sum = rank_buffer[source + 2u * lid];
    var high_sum = rank_buffer[source + 2u * lid + 1u];
    if (lid >= offset) {
      low_sum = low_sum + rank_buffer[source + 2u * (lid - offset)];
      high_sum = high_sum + rank_buffer[source + 2u * (lid - offset) + 1u];
    }
    rank_buffer[other + 2u * lid] = low_sum;
    rank_buffer[other + 2u * lid + 1u] = high_sum;
    source = other;
    workgroupBarrier();
  }
  if (valid) {
    let word = digit >> 1u;
    var packed = 0u;
    if (word < 4u) {
      packed = rank_buffer[source + 2u * lid][word];
    } else {
      packed = rank_buffer[source + 2u * lid + 1u][word - 4u];
    }
    // The inclusive count holds this key, so the rank is one less.
    let rank = ((packed >> ((digit & 1u) * 16u)) & 0xFFFFu) - 1u;
    let dest = digit_offsets[digit * blocks + block] + rank;
    out_hi[dest] = hi;
    if (scatter_params.move_lo != 0u) {
      out_lo[dest] = lo;
    }
    out_value[dest] = value;
  }
}
