from algorithm import cumsum
from time import now
from math import min
from math.limit import max_or_inf
from prefix_sum import scalar_prefix_sum, simd_prefix_sum
from prefix_sum_benchmark import benchmark

fn benchmark_other[size: Int, D: DType, func: fn(inout DynamicVector[SIMD[D, 1]]) -> None](name: StringLiteral):
    var min_duration = max_or_inf[DType.int64]()
    for _ in range(10):
        var v1 = DynamicVector[SIMD[D, 1]](size)
        v1.resize(size)
        for i in range(size):
            v1[i] = i % 4 == 0
        let tik = now()
        func(v1)
        let tok = now()
        min_duration = min(min_duration, tok - tik)
    print_no_newline(name, D, ", ")
    print(size, ",", min_duration, ",", Float64(min_duration.to_int()) / Float64(size))

fn benchmark_std[size: Int, D: DType]():
    var min_duration = max_or_inf[DType.uint64]()
    for _ in range(10):
        let p1 = DTypePointer[D].alloc(size)
        let b1 = Buffer[Dim(size), D](p1)
        let p2 = DTypePointer[D].alloc(size)
        let b2 = Buffer[Dim(size), D](p2)
        for i in range(size):
            b1[i] = i % 4 == 0
        
        let tik = now()
        cumsum[size, D](b2, b1)
        let tok = now()
        min_duration = min(min_duration, tok - tik)

    print("Std", D, ",", size, ",", min_duration, ",", Float64(min_duration.to_int()) / Float64(size))

fn main():
    benchmark_std[1 << 8, DType.int8]()
    benchmark_std[1 << 8, DType.int16]()
    benchmark_std[1 << 8, DType.int32]()
    benchmark_std[1 << 8, DType.int64]()
    benchmark_std[1 << 11, DType.int8]()
    benchmark_std[1 << 11, DType.int16]()
    benchmark_std[1 << 11, DType.int32]()
    benchmark_std[1 << 11, DType.int64]()
    benchmark_std[1 << 13, DType.int8]()
    benchmark_std[1 << 13, DType.int16]()
    benchmark_std[1 << 13, DType.int32]()
    benchmark_std[1 << 13, DType.int64]()
    benchmark_std[1 << 16, DType.int8]()
    benchmark_std[1 << 16, DType.int16]()
    benchmark_std[1 << 16, DType.int32]()
    benchmark_std[1 << 16, DType.int64]()

    benchmark_other[1 << 8, DType.int8, scalar_prefix_sum[DType.int8]]("Scalar")
    benchmark_other[1 << 8, DType.int16, scalar_prefix_sum[DType.int16]]("Scalar")
    benchmark_other[1 << 8, DType.int32, scalar_prefix_sum[DType.int32]]("Scalar")
    benchmark_other[1 << 8, DType.int64, scalar_prefix_sum[DType.int64]]("Scalar")
    benchmark_other[1 << 11, DType.int8, scalar_prefix_sum[DType.int8]]("Scalar")
    benchmark_other[1 << 11, DType.int16, scalar_prefix_sum[DType.int16]]("Scalar")
    benchmark_other[1 << 11, DType.int32, scalar_prefix_sum[DType.int32]]("Scalar")
    benchmark_other[1 << 11, DType.int64, scalar_prefix_sum[DType.int64]]("Scalar")
    benchmark_other[1 << 13, DType.int8, scalar_prefix_sum[DType.int8]]("Scalar")
    benchmark_other[1 << 13, DType.int16, scalar_prefix_sum[DType.int16]]("Scalar")
    benchmark_other[1 << 13, DType.int32, scalar_prefix_sum[DType.int32]]("Scalar")
    benchmark_other[1 << 13, DType.int64, scalar_prefix_sum[DType.int64]]("Scalar")
    benchmark_other[1 << 16, DType.int8, scalar_prefix_sum[DType.int8]]("Scalar")
    benchmark_other[1 << 16, DType.int16, scalar_prefix_sum[DType.int16]]("Scalar")
    benchmark_other[1 << 16, DType.int32, scalar_prefix_sum[DType.int32]]("Scalar")
    benchmark_other[1 << 16, DType.int64, scalar_prefix_sum[DType.int64]]("Scalar")

    benchmark_other[1 << 8, DType.int8, simd_prefix_sum[DType.int8]]("SIMD")
    benchmark_other[1 << 8, DType.int16, simd_prefix_sum[DType.int16]]("SIMD")
    benchmark_other[1 << 8, DType.int32, simd_prefix_sum[DType.int32]]("SIMD")
    benchmark_other[1 << 8, DType.int64, simd_prefix_sum[DType.int64]]("SIMD")
    benchmark_other[1 << 11, DType.int8, simd_prefix_sum[DType.int8]]("SIMD")
    benchmark_other[1 << 11, DType.int16, simd_prefix_sum[DType.int16]]("SIMD")
    benchmark_other[1 << 11, DType.int32, simd_prefix_sum[DType.int32]]("SIMD")
    benchmark_other[1 << 11, DType.int64, simd_prefix_sum[DType.int64]]("SIMD")
    benchmark_other[1 << 13, DType.int8, simd_prefix_sum[DType.int8]]("SIMD")
    benchmark_other[1 << 13, DType.int16, simd_prefix_sum[DType.int16]]("SIMD")
    benchmark_other[1 << 13, DType.int32, simd_prefix_sum[DType.int32]]("SIMD")
    benchmark_other[1 << 13, DType.int64, simd_prefix_sum[DType.int64]]("SIMD")
    benchmark_other[1 << 16, DType.int8, simd_prefix_sum[DType.int8]]("SIMD")
    benchmark_other[1 << 16, DType.int16, simd_prefix_sum[DType.int16]]("SIMD")
    benchmark_other[1 << 16, DType.int32, simd_prefix_sum[DType.int32]]("SIMD")
    benchmark_other[1 << 16, DType.int64, simd_prefix_sum[DType.int64]]("SIMD")
    