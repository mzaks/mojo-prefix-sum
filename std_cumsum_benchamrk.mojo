from algorithm import cumsum
from time import now
from math import min
from math.limit import max_or_inf

fn benchmark[size: Int, D: DType]():
    var min_duration = max_or_inf[DType.uint64]()
    for _ in range(10):
        let p1 = DTypePointer[D].alloc(size)
        let b1 = Buffer[Dim(size), D](p1)
        let p2 = DTypePointer[D].alloc(size)
        let b2 = Buffer[Dim(size), D](p2)
        for i in range(size):
            b1[i] = i % 4 == 0
        
        let tik = now()
        cumsum[size, D](p2, p1)
        let tok = now()
        min_duration = min(min_duration, tok - tik)

    print(D, ",", size, ",", min_duration, ",", Float64(min_duration.to_int()) / Float64(size))

fn main():
    benchmark[1 << 8, DType.int8]()
    benchmark[1 << 8, DType.int16]()
    benchmark[1 << 8, DType.int32]()
    benchmark[1 << 8, DType.int64]()
    benchmark[1 << 11, DType.int8]()
    benchmark[1 << 11, DType.int16]()
    benchmark[1 << 11, DType.int32]()
    benchmark[1 << 11, DType.int64]()
    benchmark[1 << 13, DType.int8]()
    benchmark[1 << 13, DType.int16]()
    benchmark[1 << 13, DType.int32]()
    benchmark[1 << 13, DType.int64]()
    benchmark[1 << 16, DType.int8]()
    benchmark[1 << 16, DType.int16]()
    benchmark[1 << 16, DType.int32]()
    benchmark[1 << 16, DType.int64]()
    