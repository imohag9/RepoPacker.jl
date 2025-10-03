using RepoPacker
using Test
using Aqua
using Random
using SHA
using LibGit2
using Logging
using JSON

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(RepoPacker;
        ambiguities = true,
        project_extras = true,
        deps_compat = true,
        stale_deps = true,
        piracies = true,
        unbound_args = true
    )
end


include("test_basic.jl")

include("test_edge_cases.jl")

include("test_metrics.jl")
