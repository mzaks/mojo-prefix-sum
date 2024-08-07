from algorithm import cumsum
from time import now
from math import min
from prefix_sum import scalar_prefix_sum, simd_prefix_sum
from prefix_sum_benchmark import benchmark
from csv import CsvBuilder
from buffer import Dim, Buffer

fn benchmark_other[size: Int, D: DType, func: fn(inout List[SIMD[D, 1]]) -> None](name: StringLiteral, inout csv_builder: CsvBuilder):
    var min_duration = 1_000_000_000
    var value = 0
    for _ in range(10):
        var v1 = List[SIMD[D, 1]](size)
        v1.resize(size, 0)
        for i in range(size):
            v1[i] = i % 4 == 0
        var tik = now()
        func(v1)
        var tok = now()
        min_duration = min(min_duration, tok - tik)
        value = v1[size - 1].to_int()

    csv_builder.push(name + String(" ") + D.__str__())
    csv_builder.push(size)
    csv_builder.push(value)
    csv_builder.push(min_duration)
    csv_builder.push( Float64(min_duration) / Float64(size))

fn benchmark_std[size: Int, D: DType](inout csv_builder: CsvBuilder):
    var min_duration = 1_000_000_000
    var value = 0
    for _ in range(10):
        var p1 = DTypePointer[D].alloc(size)
        var b1 = Buffer[D, Dim(size)](p1)
        var p2 = DTypePointer[D].alloc(size)
        var b2 = Buffer[D, Dim(size)](p2)
        for i in range(size):
            b1[i] = i % 4 == 0
        
        var tik = now()
        cumsum(b2, b1)
        var tok = now()
        min_duration = min(min_duration, tok - tik)
        value = b2[size - 1].to_int()

    csv_builder.push(String("Std ") + D.__str__())
    csv_builder.push(size)
    csv_builder.push(value)
    csv_builder.push(min_duration)
    csv_builder.push(Float64(min_duration) / Float64(size))

fn main():
    var csv_builder = CsvBuilder(5)
    benchmark_std[1 << 8, DType.int8](csv_builder)
    benchmark_std[1 << 8, DType.int16](csv_builder)
    benchmark_std[1 << 8, DType.int32](csv_builder)
    benchmark_std[1 << 8, DType.int64](csv_builder)
    benchmark_std[1 << 11, DType.int8](csv_builder)
    benchmark_std[1 << 11, DType.int16](csv_builder)
    benchmark_std[1 << 11, DType.int32](csv_builder)
    benchmark_std[1 << 11, DType.int64](csv_builder)
    benchmark_std[1 << 13, DType.int8](csv_builder)
    benchmark_std[1 << 13, DType.int16](csv_builder)
    benchmark_std[1 << 13, DType.int32](csv_builder)
    benchmark_std[1 << 13, DType.int64](csv_builder)
    benchmark_std[1 << 16, DType.int8](csv_builder)
    benchmark_std[1 << 16, DType.int16](csv_builder)
    benchmark_std[1 << 16, DType.int32](csv_builder)
    benchmark_std[1 << 16, DType.int64](csv_builder)
    benchmark_std[1 << 24, DType.int64](csv_builder)

    benchmark_other[1 << 8, DType.int8, scalar_prefix_sum[DType.int8]]("Scalar", csv_builder)
    benchmark_other[1 << 8, DType.int16, scalar_prefix_sum[DType.int16]]("Scalar", csv_builder)
    benchmark_other[1 << 8, DType.int32, scalar_prefix_sum[DType.int32]]("Scalar", csv_builder)
    benchmark_other[1 << 8, DType.int64, scalar_prefix_sum[DType.int64]]("Scalar", csv_builder)
    benchmark_other[1 << 11, DType.int8, scalar_prefix_sum[DType.int8]]("Scalar", csv_builder)
    benchmark_other[1 << 11, DType.int16, scalar_prefix_sum[DType.int16]]("Scalar", csv_builder)
    benchmark_other[1 << 11, DType.int32, scalar_prefix_sum[DType.int32]]("Scalar", csv_builder)
    benchmark_other[1 << 11, DType.int64, scalar_prefix_sum[DType.int64]]("Scalar", csv_builder)
    benchmark_other[1 << 13, DType.int8, scalar_prefix_sum[DType.int8]]("Scalar", csv_builder)
    benchmark_other[1 << 13, DType.int16, scalar_prefix_sum[DType.int16]]("Scalar", csv_builder)
    benchmark_other[1 << 13, DType.int32, scalar_prefix_sum[DType.int32]]("Scalar", csv_builder)
    benchmark_other[1 << 13, DType.int64, scalar_prefix_sum[DType.int64]]("Scalar", csv_builder)
    benchmark_other[1 << 16, DType.int8, scalar_prefix_sum[DType.int8]]("Scalar", csv_builder)
    benchmark_other[1 << 16, DType.int16, scalar_prefix_sum[DType.int16]]("Scalar", csv_builder)
    benchmark_other[1 << 16, DType.int32, scalar_prefix_sum[DType.int32]]("Scalar", csv_builder)
    benchmark_other[1 << 16, DType.int64, scalar_prefix_sum[DType.int64]]("Scalar", csv_builder)
    benchmark_other[1 << 24, DType.int64, scalar_prefix_sum[DType.int64]]("Scalar", csv_builder)

    benchmark_other[1 << 8, DType.int8, simd_prefix_sum[DType.int8]]("SIMD", csv_builder)
    benchmark_other[1 << 8, DType.int16, simd_prefix_sum[DType.int16]]("SIMD", csv_builder)
    benchmark_other[1 << 8, DType.int32, simd_prefix_sum[DType.int32]]("SIMD", csv_builder)
    benchmark_other[1 << 8, DType.int64, simd_prefix_sum[DType.int64]]("SIMD", csv_builder)
    benchmark_other[1 << 11, DType.int8, simd_prefix_sum[DType.int8]]("SIMD", csv_builder)
    benchmark_other[1 << 11, DType.int16, simd_prefix_sum[DType.int16]]("SIMD", csv_builder)
    benchmark_other[1 << 11, DType.int32, simd_prefix_sum[DType.int32]]("SIMD", csv_builder)
    benchmark_other[1 << 11, DType.int64, simd_prefix_sum[DType.int64]]("SIMD", csv_builder)
    benchmark_other[1 << 13, DType.int8, simd_prefix_sum[DType.int8]]("SIMD", csv_builder)
    benchmark_other[1 << 13, DType.int16, simd_prefix_sum[DType.int16]]("SIMD", csv_builder)
    benchmark_other[1 << 13, DType.int32, simd_prefix_sum[DType.int32]]("SIMD", csv_builder)
    benchmark_other[1 << 13, DType.int64, simd_prefix_sum[DType.int64]]("SIMD", csv_builder)
    benchmark_other[1 << 16, DType.int8, simd_prefix_sum[DType.int8]]("SIMD", csv_builder)
    benchmark_other[1 << 16, DType.int16, simd_prefix_sum[DType.int16]]("SIMD", csv_builder)
    benchmark_other[1 << 16, DType.int32, simd_prefix_sum[DType.int32]]("SIMD", csv_builder)
    benchmark_other[1 << 16, DType.int64, simd_prefix_sum[DType.int64]]("SIMD", csv_builder)
    benchmark_other[1 << 24, DType.int64, simd_prefix_sum[DType.int64]]("SIMD", csv_builder)

    print(csv_builder^.finish())
    