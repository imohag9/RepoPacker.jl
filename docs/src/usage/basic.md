# Basic Usage

RepoPacker.jl provides two main operations: packing local directories and cloning/packing Git repositories.

## Packing a Local Directory

The simplest way to use RepoPacker is to pack the current directory:

```julia
using RepoPacker

# Pack current directory as XML (default)
RepoPacker.pack_directory(".", "repo.xml")

# Pack as JSON
RepoPacker.pack_directory(".", "repo.json", output_style=:json)

# Pack as Markdown
RepoPacker.pack_directory(".", "repo.md", output_style=:markdown)
```

This will create a file containing all text files from the current directory in the specified format.

### Parameters

- `dir_path`: The directory to pack (required)
- `output_file`: The output file path (default: "repo.xml")
- `output_style`: Format to use (`:xml`, `:json`, or `:markdown`)
- `verbose`: Whether to enable detailed logging (default: false)

```julia
# Pack a specific directory with verbose logging
RepoPacker.pack_directory("/path/to/project", "project.xml", verbose=true)

# Pack in JSON format
RepoPacker.pack_directory("/path/to/project", "project.json", output_style=:json)
```

## Cloning and Packing a Git Repository

You can directly clone and pack a Git repository in one step:

```julia
using RepoPacker

# Clone and pack a GitHub repository as XML
RepoPacker.clone_and_pack("https://github.com/JuliaLang/julia.git", "julia.xml")

# Clone and pack as JSON
RepoPacker.clone_and_pack("https://github.com/JuliaLang/julia.git", "julia.json", output_style=:json)

# With verbose logging
RepoPacker.clone_and_pack("https://github.com/JuliaLang/julia.git", "julia.xml", verbose=true)
```

This will:
1. Clone the repository to a temporary directory
2. Pack the repository contents into the specified file
3. Clean up the temporary directory

### Parameters

- `repo_url`: The URL of the Git repository (required)
- `output_file`: The output file path (default: "repo.xml")
- `output_style`: Format to use (`:xml`, `:json`, or `:markdown`)
- `temp_dir`: Temporary directory for cloning (default: auto-generated)
- `verbose`: Whether to enable detailed logging (default: false)

## Understanding the Output

The generated file contains:

1. A summary section with purpose, format, and usage guidelines
2. A visual representation of the directory structure
3. Metrics about the repository:
   - Total files
   - Total characters
   - Estimated token count
   - Top files by token count
4. The contents of all text files in the repository

This format is designed to be easily parsed by AI systems while maintaining the context of the original repository structure.

