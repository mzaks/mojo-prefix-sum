from prefix_sum import scalar_prefix_sum, simd_prefix_sum
from time import now
from testing import assert_equal
import benchmark

alias LIST_SIZE = 10_000

alias dtype = DType.int64
alias type = SIMD[dtype, 1]
alias rounds = 10

fn scalar() -> DynamicVector[type]:
    var list = DynamicVector[type](capacity=LIST_SIZE)
    var min_duration = 10000000
    var result = 0
    for _ in range(rounds):
        list = DynamicVector[type](capacity=LIST_SIZE)
        for _ in range(LIST_SIZE):
            list.append(1)
        let tik = now()
        scalar_prefix_sum[dtype](list)
        let tok = now()     
        min_duration = tok - tik if (tok - tik) < min_duration else min_duration

    print("Scalar prefix over a vector with", LIST_SIZE, "items in", min_duration, "ns,", Float64(min_duration) / LIST_SIZE, "ns per item")

    return list

fn simd() -> DynamicVector[type]:
    var list = DynamicVector[type](capacity=LIST_SIZE)
    var min_duration = 10000000
    for _ in range(rounds):
        list = DynamicVector[type](capacity=LIST_SIZE)
        for _ in range(LIST_SIZE):
            list.append(1)
        let tik = now()
        simd_prefix_sum[dtype](list)
        let tok = now()
        min_duration = tok - tik if (tok - tik) < min_duration else min_duration

    print("SIMD prefix over a vector with", LIST_SIZE, "items in", min_duration, "ns,", Float64(min_duration) / LIST_SIZE, "ns per item")
    return list

fn main() raises:
    let l1 = scalar()
    let l2 = simd()
    for i in range(LIST_SIZE):
        assert_equal(l1[i], l2[i])

    # var l3 = DynamicVector[type](LIST_SIZE)
    # var l4 = DynamicVector[type](LIST_SIZE)
    # for _ in range(LIST_SIZE):
    #     l3.append(1)
    #     l4.append(1)
    # @parameter
    # fn _scalar():
    #     var l = l3
    #     scalar_prefix_sum[dtype](l)

    # @parameter
    # fn _simd():
    #     var l = l4
    #     scalar_prefix_sum[dtype](l)
    
    # let report1 = benchmark.run[_scalar](min_runtime_secs=0.5)
    # let report2 = benchmark.run[_simd](min_runtime_secs=0.5)
    # report1.print_full("ns")
    # report2.print_full("ns")