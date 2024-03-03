from time import time_ns
import numpy as np

def simple_python_prefix_sum():
    list = [1] * 10_000
    tik = time_ns()
    element = list[0]
    for i in range(1, len(list)):
        list[i] += element
        element = list[i]
    tok = time_ns()
    print(f"Time spent per element: {(tok - tik) / len(list)} ns")

def naive_numpy_prefix_sum():
    list = [1] * 10_000
    tik = time_ns()
    list = np.cumsum(list)
    tok = time_ns()
    print(f"Time spent per element: {(tok - tik) / len(list)} ns")

def proper_numpy_prefix_sum():
    list = np.full(10_000, 1)
    tik = time_ns()
    list = np.cumsum(list)
    tok = time_ns()
    print(f"Time spent per element: {(tok - tik) / len(list)} ns")

def stupid_numpy_prefix_sum():
    list = np.full(10_000, 1)
    tik = time_ns()
    element = list[0]
    for i in range(1, len(list)):
        list[i] += element
        element = list[i]
    tok = time_ns()
    print(f"Time spent per element: {(tok - tik) / len(list)} ns")

if __name__ == "__main__":
    l1 = simple_python_prefix_sum()
    l2 = naive_numpy_prefix_sum()
    l3 = proper_numpy_prefix_sum()
    l4 = stupid_numpy_prefix_sum()