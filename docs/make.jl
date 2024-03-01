using LFRBenchmarkGraphs
using Documenter

DocMeta.setdocmeta!(
    LFRBenchmarkGraphs, :DocTestSetup, :(using LFRBenchmarkGraphs); recursive=true
)

makedocs(;
    modules=[LFRBenchmarkGraphs],
    authors="Dimitris Floros",
    sitename="LFRBenchmarkGraphs.jl",
    format=Documenter.HTML(;
        canonical="https://fcdimitr.github.io/LFRBenchmarkGraphs.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/fcdimitr/LFRBenchmarkGraphs.jl", devbranch="main")
