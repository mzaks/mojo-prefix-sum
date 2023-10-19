from time import now
from random import random_float64, random_si64, random_ui64
from math import min
from math.limit import max_or_inf
from prefix_sum import scalar_prefix_sum, simd_prefix_sum

fn random_vec[D: DType](size: Int, max: Int = 3000) -> DynamicVector[SIMD[D, 1]]:
    var result = DynamicVector[SIMD[D, 1]](size)
    for _ in range(size):
        @parameter
        if D == DType.int8 or D == DType.int16 or D == DType.int32 or D == DType.int64:
            result.push_back(random_si64(0, max).cast[D]())
        elif D == DType.float16 or D == DType.float32 or D == DType.float64:
            result.push_back(random_float64(0, max).cast[D]())
        else:
            result.push_back(random_ui64(0, max).cast[D]())
    return result

fn benchmark[D: DType, func: fn(inout DynamicVector[SIMD[D, 1]]) -> None](
    name: StringLiteral, size: Int, max: Int = 3000
):
    let v = random_vec[D](size, max)
    var v1 = v.deepcopy()
    var min_duration = max_or_inf[DType.int64]()
    for _ in range(10):
        v1 = v.deepcopy()
        let tik = now()
        func(v1)
        let tok = now()
        min_duration = min(min_duration, tok - tik)
    print_no_newline(name, D)
    print(",", size, ",", max, ",", min_duration, ",", Float64(min_duration.to_int()) / Float64(size))

fn main():
    alias D = DType.int64
    for i in range(8, (1 << 16) + 1, 8):
        # benchmark[D, scalar_prefix_sum[D]]("Scalar", i, 10)
        benchmark[D, simd_prefix_sum[D]]("SIMD", i, 10)