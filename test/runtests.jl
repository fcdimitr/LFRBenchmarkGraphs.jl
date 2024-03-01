using LFRBenchmarkGraphs
using Graphs
using JuliaFormatter
using Aqua
using JET
using Documenter
using Test

@testset verbose = true "LFRBenchmarkGraphs.jl" begin
  @testset "Code quality" begin
    Aqua.test_all(
      LFRBenchmarkGraphs;
      ambiguities = false,
      deps_compat = (check_extras = false,),
    )
  end
  @testset "Code formatting" begin
    @test JuliaFormatter.format(LFRBenchmarkGraphs; verbose = false, overwrite = false)
  end
  @testset "Code linting" begin
    JET.test_package(LFRBenchmarkGraphs; target_defined_modules = true)
  end
  doctest(LFRBenchmarkGraphs)
  @testset "Lancichinetti-Fortunato-Radicchi" begin
    @testset "($n,$k_avg,$k_max,$isdir)" for n in [30, 40],
      isdir in [false, true],
      k_avg in (isdir ? [5.5, 6.0, 6.5] : [3.5, 4, 4.5]),
      k_max in ceil.(Int, [1.5 * k_avg, 2 * k_avg])

      lfr, cid =
        lancichinetti_fortunato_radicchi(n, k_avg, k_max; seed = 1, is_directed = isdir)
      @test nv(lfr) == n
      @test is_directed(lfr) == isdir
      @test length(cid) == nv(lfr)
    end
  end
end
