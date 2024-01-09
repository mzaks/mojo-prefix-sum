from algorithm.functional import vectorize
from sys.info import simdwidthof
from sys.intrinsics import compressed_store
from math import iota, reduce_bit_count, any_true
from memory import stack_allocation
from time import now
from collections.vector import UnsafeFixedVector

alias simd_width_i8 = simdwidthof[DType.int8]()

fn vectorize_and_exit[simd_width: Int, workgroup_function: fn[i: Int](Int) capturing -> Bool](size: Int):
    let loops = size // simd_width
    for i in range(loops):
        if workgroup_function[simd_width](i * simd_width):
            return
    
    var rest = size & (simd_width - 1)
    @parameter
    if simd_width >= 64:
        if rest >= 32:
            if workgroup_function[32](size - rest):
                return
            rest -= 32
    @parameter
    if simd_width >= 32:
        if rest >= 16:
            if workgroup_function[16](size - rest):
                return
            rest -= 16
    @parameter
    if simd_width >= 16:
        if rest >= 8:
            if workgroup_function[8](size - rest):
                return
            rest -= 8
    @parameter
    if simd_width >= 8:
        if rest >= 4:
            if workgroup_function[4](size - rest):
                return
            rest -= 4
    @parameter
    if simd_width >= 4:
        if rest >= 2:
            if workgroup_function[2](size - rest):
                return
            rest -= 2

    if rest == 1:
        _= workgroup_function[1](size - rest)


fn find_indices(s: String, c: String) -> DynamicVector[UInt64]:
    let size = len(s)
    var result = DynamicVector[UInt64]()
    let char = Int8(ord(c))
    let p = s._as_ptr()

    @parameter
    fn find[simd_width: Int](offset: Int):
        @parameter
        if simd_width == 1:
            if p.offset(offset).load() == char:
                return result.push_back(offset)
        else:
            let chunk = p.simd_load[simd_width](offset)
            let occurrence = chunk == char
            let offsets = iota[DType.uint64, simd_width]() + offset
            let occurrence_count = reduce_bit_count(occurrence)
            let current_len = len(result)
            result.reserve(current_len + occurrence_count)
            result.resize(current_len + occurrence_count, 0)
            compressed_store(offsets, DTypePointer[DType.uint64](result.data.value).offset(current_len), occurrence)

    vectorize[simd_width_i8, find](size)
    return result


fn occurrence_count(s: String, *c: String) -> Int:
    let size = len(s)
    var result = 0
    var chars = UnsafeFixedVector[Int8](len(c))
    for i in range(len(c)):
        chars.append(Int8(ord(__get_address_as_lvalue(c[i]))))
    let p = s._as_ptr()

    @parameter
    fn find[simd_width: Int](offset: Int):
        @parameter
        if simd_width == 1:
            for i in range(len(chars)):
                let char = chars[i]
                if p.offset(offset).load() == char:
                    result += 1
                    return
        else:
            let chunk = p.simd_load[simd_width](offset)

            var occurrence = SIMD[DType.bool, simd_width](False)
            for i in range(len(chars)):
                occurrence |= chunk == chars[i]
            let occurrence_count = reduce_bit_count(occurrence)
            result += occurrence_count

    vectorize[simd_width_i8, find](size)
    return result


fn contains_any_of(s: String, *c: String) -> Bool:
    let size = len(s)
    let c_list: VariadicListMem[String] = c
    var chars = UnsafeFixedVector[Int8](len(c_list))
    for i in range(len(c_list)):
        chars.append(Int8(ord(__get_address_as_lvalue(c[i]))))
    var p = s._as_ptr()
    var flag = False

    @parameter
    fn find[simd_width: Int](i: Int) -> Bool:
        let chunk = p.simd_load[simd_width]()
        p = p.offset(simd_width)
        for i in range(len(chars)):
            let occurrence = chunk == chars[i]
            if any_true(occurrence):
                flag = True
                return flag
        return False

    vectorize_and_exit[simd_width_i8, find](size)

    return flag


@always_inline
fn string_from_pointer(p: DTypePointer[DType.int8], length: Int) -> String:
    # Since Mojo 0.5.0 the pointer needs to provide a 0 terminated byte string
    p.store(length - 1, 0)
    return String(p, length)


fn print_v(v: DynamicVector[UInt64]):
    print_no_newline("(", len(v), ")", "[")
    for i in range(len(v)):
        print_no_newline(v[i], ",")
    print("]")
