# RepoPacker.jl

# RepoPacker [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://imohag9.github.io/RepoPacker.jl/dev/) [![Build Status](https://github.com/imohag9/RepoPacker.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/imohag9/RepoPacker.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

RepoPacker.jl is a Julia package that packs a local directory or Git remote repository into a single file in a format compatible with [Repomix](https://github.com/yamadashy/repomix), a tool designed to feed entire codebases into AI systems for analysis. This format is optimized for consumption by large language models and other AI systems that require complete repository context.

## Relationship to Repomix

RepoPacker.jl is specifically designed to generate output in the **format inspired by that used by [Repomix](https://github.com/yamadashy/repomix)**. It generates files with close structure to Repomix output, follows the same file inclusion/exclusion patterns, maintains the same directory structure representation, includes the same metadata sections required by AI analysis tools, and provides token count metrics to help with LLM context window limitations.

## Features

- Pack local directories into Repomix-compatible format
- Clone and pack Git repositories directly
- Support for multiple output formats:
  - XML (default)
  - JSON
  - Markdown
- Path exclusion patterns
- Detailed metrics:
  - Total files
  - Total characters
  - Estimated token count (using char/4 heuristic)
- Detailed logging with verbosity control
- Robust error handling


## Installation

To install the latest stable release of RepoPacker.jl, run the following command in the Julia REPL:

```julia
using Pkg
Pkg.add("RepoPacker")
```

To install the latest development version, you can install directly from GitHub:

```julia
using Pkg
Pkg.add(url="https://github.com/yourusername/RepoPacker.jl.git")
```

## Usage

### Packing a Local Directory

```julia
using RepoPacker

# Pack current directory as XML (default)
RepoPacker.pack_directory(".", "repo.xml")

# Pack as JSON
RepoPacker.pack_directory(".", "repo.json", output_style=:json)

# Pack as Markdown
RepoPacker.pack_directory(".", "repo.md", output_style=:markdown)
```

### Cloning and Packing a Git Repository

```julia
using RepoPacker

# Clone and pack a GitHub repository as XML
RepoPacker.clone_and_pack("https://github.com/JuliaLang/julia.git", "julia.xml")

# Clone and pack as JSON
RepoPacker.clone_and_pack("https://github.com/JuliaLang/julia.git", "julia.json", output_style=:json)

# With verbose logging
RepoPacker.clone_and_pack("https://github.com/JuliaLang/julia.git", "julia.xml", verbose=true)
```

## Advanced Configuration

### Customizing Text File Extensions

```julia
using RepoPacker

# Add R and SQL extensions
RepoPacker.add_extension(".r")
RepoPacker.add_extension(".sql")

# Now .r and .sql files will be included
RepoPacker.pack_directory(".", "repo.xml")
```

### Excluding Paths

```julia
using RepoPacker

# Exclude test directories and environment files
RepoPacker.neglect_path("test/")
RepoPacker.neglect_path(".env")

# Pack directory with exclusions
RepoPacker.pack_directory(".", "repo.xml")
```

## License

This package is licensed under the MIT License. See the `LICENSE` file for details.
