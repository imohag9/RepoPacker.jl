# Usage Examples

This section provides real-world examples of how to use RepoPacker.jl in various scenarios.

## Basic Repository Analysis

```julia
using RepoPacker

# Pack your project for analysis
RepoPacker.pack_directory("my_project", "my_project.xml", verbose=true)

# The resulting XML file can be processed by AI tools
println("Repository packed successfully. Output file: my_project.xml")
```

## Analyzing a GitHub Repository

```julia
using RepoPacker

# Clone and analyze a popular Julia package
RepoPacker.clone_and_pack(
    "https://github.com/FluxML/Flux.jl.git",
    "flux.xml",
    verbose=true
)

println("Flux.jl repository packed successfully")
```

## Custom Configuration for a Python Project

```julia
using RepoPacker



# Configure for a Python project
RepoPacker.neglect_path("venv/")
RepoPacker.neglect_path("__pycache__/")
RepoPacker.neglect_path(".pytest_cache/")

# Add any custom extensions needed
RepoPacker.add_extension(".ipynb")  # Include Jupyter notebooks

# Pack the Python project
RepoPacker.pack_directory("my_python_project", "python_project.xml")

println("Python project packed successfully")
```

## Analyzing Multiple Repositories

```julia
using RepoPacker

repositories = [
    ("JuliaLang/julia", "julia.xml"),
    ("FluxML/Flux.jl", "flux.xml"),
    ("korsbo/LatentDiffEq.jl", "latendiffeq.xml")
]

for (repo, output) in repositories
    println("Processing $repo...")
    try
        RepoPacker.clone_and_pack(
            "https://github.com/$repo.git",
            output,
            verbose=true
        )
        println("✓ Successfully processed $repo")
    catch e
        println("✗ Failed to process $repo: $e")
    end
end
```



## Using JSON Output with jq

When using JSON output, you can process it with command-line tools like `jq`:

```julia
# Generate JSON output
RepoPacker.pack_directory(".", "repo.json", output_style=:json)
```

```bash
# List all files
cat repo.json | jq -r '.files | keys[]'

# Get total token count
cat repo.json | jq '.metrics.totalTokens'

# Extract specific file
cat repo.json | jq -r '.files["src/RepoPacker.jl"]'

# Show top 3 files by token count
cat repo.json | jq -r '.metrics.fileTokenCounts | to_entries | sort_by(-.value) | .[0:3] | .[] | "\(.key): \(.value) tokens"'
```

## Using Markdown Output for Documentation

Markdown output is particularly useful for documentation:

```julia
# Generate Markdown output
RepoPacker.pack_directory(".", "documentation.md", output_style=:markdown)
```

This creates a human-readable document that can be viewed in any Markdown viewer or converted to HTML/PDF.

## Token-Aware Repository Packing

When working with LLMs that have context window limits, you can use token metrics to guide your analysis:

```julia
using RepoPacker

# Pack the repository
RepoPacker.pack_directory(".", "repo.json", output_style=:json)

# Parse the JSON to get metrics
using JSON
metrics = JSON.parsefile("repo.json")["metrics"]

println("Total tokens: $(metrics["totalTokens"])")
println("Top files by token count:")

# Display top 5 files
for (path, tokens) in sort(collect(metrics["fileTokenCounts"]), by=x->x[2], rev=true)[1:min(5, length(metrics["fileTokenCounts"]))]
    println("- $path: $tokens tokens")
end

# Check if within common context window limits
if metrics["totalTokens"] > 128000
    println("Warning: Total tokens exceed 128K context window")
elseif metrics["totalTokens"] > 32000
    println("Note: Total tokens exceed 32K context window")
end
```

