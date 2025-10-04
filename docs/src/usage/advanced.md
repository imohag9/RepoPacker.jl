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
@show RepoPacker.TEXT_FILE_EXTENSIONS
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

## Advanced Path Neglect and Resetting

### NEGLECT_PATHS

The `NEGLECT_PATHS` constant is a global set of paths (files or directories) that will be excluded from the packing process. You can add paths to this set using the `neglect_path()` function, as described above.

```julia
using RepoPacker

# Exclude specific paths
RepoPacker.neglect_path("test/")
RepoPacker.neglect_path(".env")
```

These paths are matched as substrings in the full file path during the collection process.

You can always access it :

```julia
using RepoPacker
@show RepoPacker.NEGLECT_PATHS
```

### Resetting Configuration

For testing or other advanced scenarios, you might need to reset the global state of RepoPacker, including the `NEGLECT_PATHS` and the list of recognized text file extensions. The `reset!()` function is provided for this purpose.

```julia
using RepoPacker

# Reset all configurations to default
RepoPacker.reset!()
```

**Warning:** This function  clears all custom configurations and resets to the default state.