from algorithm import unroll
# from math.bit import bit_length
from vector_utils import vector

@always_inline
fn scalar_prefix_sum[D: DType](inout array: DynamicVector[SIMD[D, 1]]):
    var element = array[0]
    for i in range(1, len(array)):
        array[i] += element
        element = array[i]

@always_inline
fn _sum[width: Int, alignment: Int, loops: Int, D: DType](pointer: DTypePointer[D], carry_over: SIMD[D, 1]) -> SIMD[D, width]:
    var result = pointer.aligned_simd_load[width, alignment]()
    
    @parameter
    fn add[i: Int]():
        result += result.shift_right[1 << i]()
    
    unroll[loops, add]()

    result += carry_over
    return result

@always_inline
fn simd_prefix_sum[D: DType](inout array: DynamicVector[SIMD[D, 1]]):
    
    @parameter 
    fn inner_func[width: Int, alignment: Int, loops: Int]():
        let length = len(array)
        let numbers = DTypePointer[D](array.data)
        var c: SIMD[D, 1] = 0
        var i = 0

        while i + width <= length:
            let part = _sum[width, alignment, loops, D](numbers.offset(i), c)
            c = part[width - 1]
            numbers.simd_store(i, part)
            i += width

        @parameter
        fn add_rest[round: Int]():
            alias index = round + 1
            alias w = width >> index
            if i + w <= length:
                let part = _sum[w, alignment, loops - index, D](numbers.offset(i), c)
                c = part[w - 1]
                numbers.simd_store(i, part)
                i += w    

        unroll[loops, add_rest]()

    @parameter
    if D == DType.uint32 or D == DType.int32 or D == DType.float32:
        inner_func[64, 4, 6]()
    elif D == DType.uint16 or D == DType.int16 or D == DType.float16:
        inner_func[128, 2, 7]()
    elif D == DType.uint8 or D == DType.int8:
        inner_func[256, 1, 8]()
    else:
        inner_func[32, 8, 5]()
    
    

fn main():
    alias D = DType.uint64
    let length = (1 << 8) + 157
    var v1 = DynamicVector[SIMD[D, 1]](length)
    var v2 = DynamicVector[SIMD[D, 1]](length)
    for i in range(1, length + 1):
        v1.push_back(i)
        v2.push_back(i)

    scalar_prefix_sum[D](v1)
    simd_prefix_sum[D](v2)

    for i in range(length):
        if v1[i] != v2[i]:
            print("Index", i, "is not equal")

    print("Done!!!")