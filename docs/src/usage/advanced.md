# Advanced Configuration

RepoPacker.jl offers several configuration options to customize how repositories are packed.

## Customizing Text File Extensions

By default, RepoPacker recognizes common text file extensions. You can add custom extensions using `add_extension()`:

```julia
using RepoPacker

# Add R and SQL extensions
RepoPacker.add_extension(".r")
RepoPacker.add_extension(".sql")

# Now .r and .sql files will be included
RepoPacker.pack_directory(".", "repo.xml")
```

### Default Extensions

The default set of text file extensions includes:

```julia
using RepoPacker
RepoPacker.TEXT_FILE_EXTENSIONS
```

## Excluding Paths

You can exclude specific files or directories from the packing process using `neglect_path()`:

```julia
using RepoPacker

# Exclude test directories and environment files
RepoPacker.neglect_path("test/")
RepoPacker.neglect_path(".env")

# Pack directory with exclusions
RepoPacker.pack_directory(".", "repo.xml")
```

### Path Matching Rules

- Paths are matched as substrings in the full file path
- Both absolute and relative paths are checked
- Patterns can match anywhere in the path

Examples:
```julia
# Exclude all .log files anywhere in the repository
RepoPacker.neglect_path(".log")

# Exclude the docs directory
RepoPacker.neglect_path("docs/")

# Exclude files in a specific subdirectory
RepoPacker.neglect_path("src/legacy/")
```

## Checking File Types

You can check if a file would be considered a text file by RepoPacker:

```julia
using RepoPacker

RepoPacker.is_text_file("src/RepoPacker.jl")  # returns true
RepoPacker.is_text_file("docs/logo.png")      # returns false
```




## Empty Directory Handling

When no text files are found, RepoPacker creates a minimal valid output:

```julia
using RepoPacker

# Create an empty directory
empty_dir = mktempdir()

# Pack the empty directory
RepoPacker.pack_directory(empty_dir, "empty.xml")

# The resulting file will contain a message indicating no text files were found
```

This ensures that the output file is always valid, even when no content is available.