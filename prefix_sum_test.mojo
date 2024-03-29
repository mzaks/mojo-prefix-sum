from prefix_sum import scalar_prefix_sum, simd_prefix_sum

fn main():
    alias D = DType.uint64
    var length = (1 << 8) + 157
    var v1 = List[SIMD[D, 1]](length)
    var v2 = List[SIMD[D, 1]](length)
    for i in range(1, length + 1):
        v1.append(i)
        v2.append(i)

    scalar_prefix_sum[D](v1)
    simd_prefix_sum[D](v2)

    for i in range(length):
        if v1[i] != v2[i]:
            print("Index", i, "is not equal")

    print("Done!!!")