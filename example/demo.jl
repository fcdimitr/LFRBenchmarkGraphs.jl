# ### Dependencies for this demo
# Import the necessary packages and activate the environment

using Pkg
Pkg.activate(".")
using GraphMakie, CairoMakie, LFRBenchmarkGraphs, Graphs

# ### Graph generation
# 
# Generate an example LFR graph using the LFR benchmark. The LFR benchmark is a popular benchmark
# for community detection algorithms. It generates graphs with a power-law degree distribution and a
# community structure.

g, cid = lancichinetti_fortunato_radicchi(1000, 15, 40);

# ### Visualize graph
# 
# We use the `GraphMakie` package to visualize the graph, with the default layout algorithm.

f = Figure()
ax =
  Axis(f[1, 1]; title = "LFR graph", xticklabelsvisible = false, yticklabelsvisible = false)
graphplot!(ax, g; edge_width = 0.1, node_color = cid, node_size = 6)
colsize!(f.layout, 1, Aspect(1, 1.0))
resize_to_layout!(f)
f
