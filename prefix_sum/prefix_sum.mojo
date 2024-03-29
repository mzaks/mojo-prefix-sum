from utils.loop import unroll

@always_inline
fn scalar_prefix_sum[D: DType](inout array: List[SIMD[D, 1]]):
    var element = array[0]
    for i in range(1, len(array)):
        array[i] += element
        element = array[i]

@always_inline
fn _sum[width: Int, alignment: Int, loops: Int, D: DType](pointer: DTypePointer[D], carry_over: SIMD[D, 1]) -> SIMD[D, width]:
    var result = pointer.load[width=width]()
    
    @parameter
    fn add[i: Int]():
        result += result.shift_right[1 << i]()
    
    unroll[add, loops]()

    result += carry_over
    return result

@always_inline
fn simd_prefix_sum[D: DType](inout array: List[SIMD[D, 1]]):
    
    @parameter 
    fn inner_func[width: Int, alignment: Int, loops: Int]():
        var length = len(array)
        var numbers = DTypePointer[D](array.data.value)
        var c: SIMD[D, 1] = 0
        var i = 0

        while i + width <= length:
            var part = _sum[width, alignment, loops, D](numbers.offset(i), c)
            c = part[width - 1]
            numbers.store(i, part)
            i += width

        @parameter
        fn add_rest[round: Int]():
            alias index = round + 1
            alias w = width >> index
            if i + w <= length:
                var part = _sum[w, alignment, loops - index, D](numbers.offset(i), c)
                c = part[w - 1]
                numbers.store(i, part)
                i += w    

        unroll[add_rest, loops]()

    @parameter
    if D == DType.uint32 or D == DType.int32 or D == DType.float32:
        alias loops = 6
        inner_func[1 << loops, 4, loops]()
    elif D == DType.uint16 or D == DType.int16 or D == DType.float16:
        alias loops = 7
        inner_func[1 << loops, 2, loops]()
    elif D == DType.uint8 or D == DType.int8:
        alias loops = 8
        inner_func[1 << loops, 1, loops]()
    else:
        alias loops = 5
        inner_func[1 << loops, 8, loops]()
