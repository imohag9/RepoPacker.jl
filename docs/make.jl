using RepoPacker
using Documenter

DocMeta.setdocmeta!(RepoPacker, :DocTestSetup, :(using RepoPacker); recursive=true)

makedocs(;
    modules=[RepoPacker],
    authors="imohag9 <souidi.hamza90@gmail.com> and contributors",
    sitename="RepoPacker.jl",
    format=Documenter.HTML(;
        canonical="https://imohag9.github.io/RepoPacker.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Installation" => "installation.md",
        "Basic Usage" => "usage/basic.md",
        "Advanced Configuration" => "usage/advanced.md",
        "Examples" => "usage/examples.md",
        "API Reference" => "api.md"
    ],
)

deploydocs(;
    repo="github.com/imohag9/RepoPacker.jl",
    devbranch="main",
)
