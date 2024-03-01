module LFRBenchmarkGraphs

using Graphs, lfr_benchmark_jll

export lancichinetti_fortunato_radicchi

"""
    lancichinetti_fortunato_radicchi(n::Integer, k_avg::Integer, k_max::Integer)

Create a [Lancichinetti-Fortunato-Radicchi
model](https://en.wikipedia.org/wiki/Lancichinetti-Fortunato-Radicchi_benchmark) random
graph with `n` vertices, `k_avg` average degree, and `k_max` maximum degree. The model
generates graphs with a power-law degree distribution and community structure. Abstractly,
we can think of it as an SBM with power-law distribution for the community size and the
degree distribution.

### Optional Arguments
- `is_directed=false`: if true, return a directed graph.
- `seed=1`: set the random seed.
- `tau=2.0`: exponent for the power-law degree distribution for degree distribution.
- `tau2=1.0`: exponent for the power-law degree distribution for community size
  distribution.
- `nmin=nothing`, `nmax=nothing`: minimum and maximum (range) for community sizes.
- `overlapping_nodes=0`: number of overlapping nodes.
- `overlap_membership=0`: number of memberships for overlapping nodes.

### Notes
Depending on the input parameter combination, the function may not converge to a solution.
If this happens, try different input parameters.

### References
- Benchmarks for testing community detection algorithms on directed and weighted graphs with
  overlapping communities, Andrea Lancichinetti and Santo Fortunato, 2009.
  [https://doi.org/10.1103/PhysRevE.80.016118](https://doi.org/10.1103/PhysRevE.80.016118)
- Benchmark graphs for testing community detection algorithms, Andrea Lancichinetti, Santo
  Fortunato, and Filippo Radicchi, 2008.
  [https://doi.org/10.1103/PhysRevE.78.046110](https://doi.org/10.1103/PhysRevE.78.046110)
- Link to [the original source code by the
  authors](https://sites.google.com/site/andrealancichinetti/benchmarks?authuser=0)

## Examples
```jldoctest
julia> using LFRBenchmarkGraphs

julia> g,cid = lancichinetti_fortunato_radicchi(20, 4, 5);

julia> g
{20, 35} undirected simple Int64 graph

julia> println(cid)  # community labels
[1, 1, 3, 2, 3, 2, 1, 2, 1, 1, 1, 3, 1, 3, 2, 3, 3, 1, 2, 3]

```
"""
function lancichinetti_fortunato_radicchi(
    n::Integer, k_avg::Real, k_max::Integer; is_directed=false, kwargs...
)

    # make some basic checks
    n < 4 && throw(ArgumentError("number of vertices must be at least 4"))
    k_avg < 2.1 && throw(ArgumentError("average degree must be at least 2.1"))
    k_max >= n - 1 && throw(ArgumentError("maximum degree must be at most n-1"))
    k_max < k_avg &&
        throw(ArgumentError("maximum degree must be at least the average degree"))

    # decide directed or undirected
    g = is_directed ? SimpleDiGraph(n) : SimpleGraph(n)
    g, cid = lancichinetti_fortunato_radicchi!(g, k_avg, k_max; kwargs...)

    isempty(cid) && throw(ArgumentError("Function timed out. Check input parameters."))

    return g, cid
end

function lancichinetti_fortunato_radicchi!(
    g::SimpleGraph,
    k_avg::Real,
    k_max::Real;
    nmin::Union{Nothing,Integer}=nothing,
    nmax::Union{Nothing,Integer}=nothing,
    tau::Real=2.0,
    tau2::Real=1.0,
    fixed_range::Bool=!isnothing(nmax) && !isnothing(nmin),
    mixing_parameter::Real=0.1,
    overlapping_nodes::Integer=0,
    overlap_membership::Integer=0,
    excess::Bool=false,
    defect::Bool=false,
    seed::Integer=1,
    clustering_coeff::Union{Nothing,Real}=nothing,
)::Tuple{SimpleGraph,Vector{Int}}

    # the default "nothing" value for LFR library
    LFR_UNLIKELY = -214741

    n = nv(g)

    X = redirect_stdout(devnull) do
        return ccall(
            ("benchmark", liblfrsymmunwgt),
            Ptr{Cint},
            (
                Cint,
                Cint,
                Cint,
                Cdouble,
                Cint,
                Cdouble,
                Cdouble,
                Cdouble,
                Cint,
                Cint,
                Cint,
                Cint,
                Cint,
                Cdouble,
                Cint,
            ),
            excess,
            defect,
            n,
            k_avg,
            k_max,
            tau,
            tau2,
            mixing_parameter,
            overlapping_nodes,
            overlap_membership,
            isnothing(nmin) ? LFR_UNLIKELY : nmin,
            isnothing(nmax) ? LFR_UNLIKELY : nmax,
            fixed_range,
            isnothing(clustering_coeff) ? LFR_UNLIKELY : clustering_coeff,
            seed,
        )
    end

    if isequal(X, Ptr{Cint}(C_NULL))
        throw(
            ArgumentError(
                "Error in parameter input. Check average degree, maximum degree, and number of nodes.",
            ),
        )
    end
    n = unsafe_load(X)
    m = unsafe_load(X + sizeof(Cint))

    X = unsafe_wrap(Array{Cint}, X, 2 + n + 2 * m; own=true)

    for i in 3:2:(2 * m + 2)
        add_edge!(g, X[i], X[i + 1])
    end
    cid = Int64.(X[(2 * m + 3):end])

    return g, cid
end

function lancichinetti_fortunato_radicchi!(
    g::SimpleDiGraph,
    k_avg::Real,
    k_max::Real;
    nmin::Union{Nothing,Integer}=nothing,
    nmax::Union{Nothing,Integer}=nothing,
    tau::Real=2.0,
    tau2::Real=1.0,
    fixed_range::Bool=!isnothing(nmax) && !isnothing(nmin),
    mixing_parameter::Real=0.1,
    overlapping_nodes::Integer=0,
    overlap_membership::Integer=0,
    excess::Bool=false,
    defect::Bool=false,
    seed::Integer=1,
)::Tuple{SimpleDiGraph,Vector{Int}}

    # the default "nothing" value for LFR library
    LFR_UNLIKELY = -214741

    n = nv(g)

    X = redirect_stdout(devnull) do
        return ccall(
            ("benchmark", liblfrnonsymmunwgt),
            Ptr{Cint},
            (
                Cint,
                Cint,
                Cint,
                Cdouble,
                Cint,
                Cdouble,
                Cdouble,
                Cdouble,
                Cint,
                Cint,
                Cint,
                Cint,
                Cint,
                Cint,
            ),
            excess,
            defect,
            n,
            k_avg / 2,
            k_max,
            tau,
            tau2,
            mixing_parameter,
            overlapping_nodes,
            overlap_membership,
            isnothing(nmin) ? LFR_UNLIKELY : nmin,
            isnothing(nmax) ? LFR_UNLIKELY : nmax,
            fixed_range,
            seed,
        )
    end

    if isequal(X, Ptr{Cint}(C_NULL))
        throw(
            ArgumentError(
                "Error in parameter input. Check average degree, maximum degree, and number of nodes.",
            ),
        )
    end

    n = unsafe_load(X)
    m = unsafe_load(X + sizeof(Cint))

    X = unsafe_wrap(Array{Cint}, X, 2 + n + 2 * m; own=true)

    for i in 3:2:(2 * m + 2)
        add_edge!(g, X[i], X[i + 1])
    end
    cid = Int64.(X[(2 * m + 3):end])

    return g, cid
end

end
