from time import now
from random import random_float64, random_si64, random_ui64
from math import min
from prefix_sum import scalar_prefix_sum, simd_prefix_sum
from csv import CsvBuilder

fn random_vec[D: DType](size: Int, max: Int = 3000) -> List[SIMD[D, 1]]:
    var result = List[SIMD[D, 1]](size)
    for _ in range(size):
        @parameter
        if D == DType.int8 or D == DType.int16 or D == DType.int32 or D == DType.int64:
            result.append(random_si64(0, max).cast[D]())
        elif D == DType.float16 or D == DType.float32 or D == DType.float64:
            result.append(random_float64(0, max).cast[D]())
        else:
            result.append(random_ui64(0, max).cast[D]())
    return result

fn benchmark[D: DType, func: fn(inout List[SIMD[D, 1]]) -> None](
    name: StringLiteral, inout csv_builder: CsvBuilder, size: Int, max: Int = 3000
):
    var v = random_vec[D](size, max)
    var v1 = v
    var min_duration = 1_000_000_000
    for _ in range(10):
        v1 = v
        var tik = now()
        func(v1)
        var tok = now()
        min_duration = min(min_duration, tok - tik)
    var op_name = name + String(" ") + D.__str__()
    csv_builder.push(op_name)
    csv_builder.push(size)
    csv_builder.push(max)
    csv_builder.push(min_duration)
    csv_builder.push(Float64(min_duration) / Float64(size))

fn main():
    alias D = DType.int32
    var csv_builder = CsvBuilder(5)
    for i in range(8, (1 << 10) + 1, 1):
        benchmark[D, scalar_prefix_sum[D]]("Scalar", csv_builder, i, 10)
        benchmark[D, simd_prefix_sum[D]]("SIMD", csv_builder, i, 10)

    print(csv_builder^.finish())