using LFRBenchmarkGraphs
using BenchmarkTools

SUITE = BenchmarkGroup()
SUITE["rand"] = @benchmarkable rand(10)

# [WIP] Write your benchmarks here.
