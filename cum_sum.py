import math
import numpy as np
import time

LIST_SIZE = 1 << 20
ROUNDS = 10

def cum_sum_python():
    min_duration = 100000000000
    for _ in range(ROUNDS):
        l = [1] * LIST_SIZE
        tik = time.time_ns()
        for i in range(1, len(l)):
            l[i] += l[i-1]
        tok = time.time_ns()
        min_duration = min(min_duration, tok - tik)

    print(f"Cumulative sum over a list with {LIST_SIZE} items in {min_duration} ns, {(min_duration) / LIST_SIZE} ns per item")
    return l

def cum_sum_numpy_brutforce():
    min_duration = 100000000000
    for _ in range(ROUNDS):
        arr = np.full(LIST_SIZE, 1)
        tik = time.time_ns()
        for i in range(1, len(arr)):
            arr[i] += arr[i-1]
        tok = time.time_ns()
        min_duration = min(min_duration, tok - tik)
    print(f"Cumulative sum over numpy array with {LIST_SIZE} items in for loop in {min_duration} ns, {(min_duration) / LIST_SIZE} ns per item")
    return list(arr)

def cum_sum_numpy_shift():
    min_duration = 100000000000
    for _ in range(ROUNDS):
        arr = np.full(LIST_SIZE, 1)
        tik = time.time_ns()
        for i in range(int(math.log2(LIST_SIZE))):
            chunk = 1 << i
            shifted = np.roll(arr, chunk)
            shifted[:chunk] = 0
            arr += shifted
        tok = time.time_ns()
        min_duration = min(min_duration, tok - tik)
    print(f"Cumulative sum over numpy array with {LIST_SIZE} items with shifted addition in {min_duration} ns, {(min_duration) / LIST_SIZE} ns per item")
    return list(arr)

def cum_sum_numpy():
    min_duration = 100000000000
    for _ in range(ROUNDS):
        l = [1] * LIST_SIZE
        tik = time.time_ns()
        arr = np.cumsum(l)
        tok = time.time_ns()
        min_duration = min(min_duration, tok - tik)
    print(f"Cumulative sum over a list with {LIST_SIZE} items through numpy in {min_duration} ns, {(min_duration) / LIST_SIZE} ns per item")
    return list(arr)

def cum_sum_numpy_explicit_conversion():
    min_duration = 100000000000
    for _ in range(ROUNDS):
        arr = np.full(LIST_SIZE, 1)
        tik = time.time_ns()
        arr = arr.cumsum()
        tok = time.time_ns()
        min_duration = min(min_duration, tok - tik)
    
    print(f"Cumulative sum over a np array with {LIST_SIZE} items in {tok - tik} ns, {(tok - tik) / LIST_SIZE} ns per item")
    return list(arr)

if __name__ == "__main__":
    l1 = cum_sum_python()
    l2 = cum_sum_numpy()
    l3 = cum_sum_numpy_explicit_conversion()
    l4 = cum_sum_numpy_brutforce()
    l5 = cum_sum_numpy_shift()
    assert l1 == l2
    assert l2 == l3
    assert l3 == l4
    assert l4 == l5