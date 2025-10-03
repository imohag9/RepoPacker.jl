# Installation

RepoPacker.jl is available through the Julia package registry and can be installed with the Julia package manager.

## Installing the Stable Release

To install the latest stable release of RepoPacker.jl, run the following command in the Julia REPL:

```julia
using Pkg
Pkg.add("RepoPacker")
```

## Installing the Development Version

If you want the latest development version, you can install directly from GitHub:

```julia
using Pkg
Pkg.add(url="https://github.com/yourusername/RepoPacker.jl.git")
```

## Verifying Installation

After installation, you can verify that RepoPacker is working correctly by running the test suite:

```julia
using Pkg
Pkg.test("RepoPacker")
```

## Dependencies

RepoPacker.jl depends on the following packages:

- `LibGit2.jl`: For Git repository operations
- `XML.jl`: For XML document generation
- `JSON.jl`: For JSON document generation

These dependencies will be automatically installed when you install RepoPacker.jl.

