from prefix_sum import scalar_prefix_sum, simd_prefix_sum

fn main():
    alias D = DType.uint64
    let length = (1 << 8) + 157
    var v1 = DynamicVector[SIMD[D, 1]](capacity=length)
    var v2 = DynamicVector[SIMD[D, 1]](capacity=length)
    for i in range(1, length + 1):
        v1.push_back(i)
        v2.push_back(i)

    scalar_prefix_sum[D](v1)
    simd_prefix_sum[D](v2)

    for i in range(length):
        if v1[i] != v2[i]:
            print("Index", i, "is not equal")

    print("Done!!!")