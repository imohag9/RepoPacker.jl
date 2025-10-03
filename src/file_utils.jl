"""
    File Utilities Module

This module contains functions for collecting, filtering, and analyzing files
in a directory structure.
"""

# Common text file extensions
const TEXT_FILE_EXTENSIONS = Set{String}([
    ".py",      # Python
    ".js",      # JavaScript
    ".ts",      # TypeScript
    ".jsx",     # React JSX
    ".tsx",     # TypeScript + JSX
    ".html",    # HTML
    ".htm",     # HTML (alternative)
    ".css",     # CSS
    ".scss",    # SASS
    ".sass",    # SASS
    ".java",    # Java
    ".cpp",     # C++
    ".cxx",     # C++
    ".cc",      # C++
    ".c",       # C
    ".h",       # C/C++ Header
    ".hpp",     # C++ Header
    ".go",      # Go
    ".rs",      # Rust
    ".rb",      # Ruby
    ".php",     # PHP
    ".swift",   # Swift
    ".kt",      # Kotlin
    ".kts",     # Kotlin Script
    ".cs",      # C#
    ".fs",      # F#
    ".fsx",     # F# Script
    ".scala",   # Scala
    ".sc",      # Scala Script
    ".pl",      # Perl
    ".pm",      # Perl Module
    ".t",       # Perl Test
    ".lua",     # Lua
    ".dart",    # Dart
    ".erl",     # Erlang
    ".hrl",     # Erlang Header
    ".ex",      # Elixir
    ".exs",     # Elixir Script
    ".clj",     # Clojure
    ".cljs",    # ClojureScript
    ".edn",     # Extensible Data Notation
    ".groovy",  # Groovy
    ".gvy",     # Groovy
    ".gy",      # Groovy
    ".gsh",     # Groovy Shell
    ".hs",      # Haskell
    ".lhs",     # Literate Haskell
    ".ml",      # OCaml / Standard ML
    ".mli",     # OCaml Interface
    ".v",       # Verilog
    ".sv",      # SystemVerilog
    ".svh",     # SystemVerilog Header
    ".vhdl",    # VHDL
    ".vhd",     # VHDL
    ".asm",     # Assembly
    ".s",       # Assembly (GAS)
    ".S",       # Preprocessed Assembly
    ".p",       # Pascal
    ".pas",     # Pascal
    ".d",       # D Language
    ".jl",      # Julia
    ".nim",     # Nim
    ".zig",     # Zig
    ".odin",    # Odin
    ".f",       # Fortran
    ".for",     # Fortran
    ".f90",     # Fortran 90
    ".f95",     # Fortran 95
    ".coffee",  # CoffeeScript
    ".ls",      # LiveScript
    ".elm",     # Elm
    ".r",       # R
    ".R",       # R script
    ".Rmd",     # R Markdown
    ".sql",     # SQL
    ".ddl",     # Data Definition Language
    ".dml",     # Data Manipulation Language
    ".prql",    # PRQL
    ".json",    # JSON
    ".jsonc",   # JSON with Comments
    ".xml",     # XML
    ".yml",     # YAML
    ".yaml",    # YAML
    ".toml",    # TOML
    ".ini",     # INI config
    ".cfg",     # Config
    ".conf",    # Config (Unix)
    ".env",     # Environment variables
    ".dotenv",  # Alternative .env name
    ".properties", # Java Properties
    ".plist",   # Property List (Apple)
    ".reg",     # Windows Registry (text-based)
    ".desktop", # Linux Desktop Entry
    ".service", # systemd service (text)
    ".sh",      # Shell script
    ".bash",    # Bash script
    ".zsh",     # Zsh script
    ".fish",    # Fish shell
    ".ps1",     # PowerShell
    ".bat",     # Windows Batch
    ".cmd",     # CMD script
    ".vbs",     # VBScript
    ".ahk",     # AutoHotkey
    ".md",      # Markdown
    ".markdown",# Markdown
    ".adoc",    # AsciiDoc
    ".rst",     # reStructuredText
    ".txt",     # Plain text
    ".log",     # Log file
    ".tex",     # LaTeX
    ".sty",     # LaTeX Style
    ".bib",     # BibTeX
    ".cmake",   # CMake script
    ".gradle",  # Gradle build
    ".podspec", # CocoaPods spec
    ".gemspec", # Ruby gem spec
    ".prettierrc",  # Prettier config
    ".eslintrc",    # ESLint config
    ".babelrc",     # Babel config
    ".tf",          # Terraform
    ".tfvars",      # Terraform variables
    ".hcl",         # HCL (Terraform, Vault)
    ".wat",         # WebAssembly Text Format
    ".rss",         # RSS feed
    ".atom",        # Atom feed
    ".csv",         # CSV
    ".tsv",         # TSV
    ".ndjson",      # Newline-delimited JSON
    ".geojson",     # GeoJSON
    ".proto",       # Protocol Buffers
])

# Global set of paths to neglect (relative or absolute patterns)
const NEGLECT_PATHS = Set{String}()

"""
    add_extension(ext::AbstractString)

Add a file extension (e.g., ".r", ".sql") to the list of recognized text file extensions.
The extension should include the leading dot.

# Arguments
- `ext`: File extension to add (must start with a dot)

# Examples
```julia
RepoPacker.add_extension(".r")
RepoPacker.add_extension(".sql")
```

# Errors
- Throws `ArgumentError` if extension doesn't start with a dot
"""
function add_extension(ext::AbstractString)
    if !startswith(ext, '.')
        throw(ArgumentError("Extension must start with a dot, e.g., \".r\""))
    end
    push!(TEXT_FILE_EXTENSIONS, lowercase(ext))
    @debug "Added extension to text file list" extension=ext
    return nothing
end

"""
    neglect_path(path::AbstractString)

Add a path (file or directory) to be excluded from packing.
Paths are matched as substrings in the full file path (relative to repo root).

# Arguments
- `path`: Path pattern to exclude (can be relative or absolute)

# Examples
```julia
RepoPacker.neglect_path("test/")
RepoPacker.neglect_path(".env")
```
"""
function neglect_path(path::AbstractString)
    push!(NEGLECT_PATHS, path)
    @debug "Added path to neglect list" path=path
    return nothing
end

"""
    is_text_file(path::AbstractString)

Check if a file is a text file based on its extension.

# Arguments
- `path`: File path to check

# Returns
- `true` if the file has a recognized text extension, `false` otherwise

# Examples
```julia
RepoPacker.is_text_file("src/RepoPacker.jl")  # returns true
RepoPacker.is_text_file("docs/logo.png")      # returns false
```
"""
function is_text_file(path::AbstractString)
    ext = lowercase(splitext(path)[2])
    return ext in TEXT_FILE_EXTENSIONS
end

"""
    should_neglect(full_path::AbstractString, base_dir::AbstractString)

Check if a file should be excluded based on the global NEGLECT_PATHS list.
Compares against both absolute and relative (to base_dir) paths.

# Arguments
- `full_path`: Absolute path of the file
- `base_dir`: Base directory of the repository

# Returns
- `true` if the file should be excluded, `false` otherwise
"""
function should_neglect(full_path::AbstractString, base_dir::AbstractString)
    rel = relpath(full_path, base_dir)
    for pattern in NEGLECT_PATHS
        if contains(full_path, pattern) || contains(rel, pattern)
            return true
        end
    end
    return false
end

"""
    collect_text_files(dir_path::AbstractString; verbose::Bool=false)

Recursively collect all text files in a directory, skipping .git and neglected paths.

# Arguments
- `dir_path`: Directory path to scan
- `verbose`: Whether to enable detailed logging (default: false)

# Returns
- Vector of text file paths

# Examples
```julia
files = RepoPacker.collect_text_files(".")
```

# Errors
- Throws `ArgumentError` if directory doesn't exist
"""
function collect_text_files(dir_path::AbstractString; verbose::Bool=false)
    if !isdir(dir_path)
        throw(ArgumentError("Directory does not exist: $dir_path"))
    end
    
    logger = verbose ? ConsoleLogger(stderr, Logging.Info) : NullLogger()
    text_files = String[]
    dir_count = 0
    file_count = 0
    
    with_logger(logger) do
        @info "Scanning directory for text files" directory=dir_path
        for (root, _, files) in walkdir(dir_path)
            dir_count += 1
            if contains(root, ".git")
                @debug "Skipping .git directory" path=root
                continue
            end
            
            for file in files
                file_path = joinpath(root, file)
                if should_neglect(file_path, dir_path)
                    @debug "Skipping neglected path" path=file_path
                    continue
                end
                
                if is_text_file(file_path)
                    push!(text_files, file_path)
                    file_count += 1
                    @debug "Including text file" path=file_path
                else
                    @debug "Skipping non-text file" path=file_path
                end
            end
        end
        @info "Text file collection complete" total_files=file_count directories_scanned=dir_count
    end
    return text_files
end

"""
    get_directory_structure(dir_path::AbstractString; verbose::Bool=false)

Generate a visual representation of the directory structure, excluding neglected paths.

# Arguments
- `dir_path`: Directory path to analyze
- `verbose`: Whether to enable detailed logging (default: false)

# Returns
- String representation of the directory structure

# Examples
```julia
structure = RepoPacker.get_directory_structure(".")
println(structure)
```
"""
function get_directory_structure(dir_path::AbstractString; verbose::Bool=false)
    logger = verbose ? ConsoleLogger(stderr, Logging.Info) : NullLogger()
    lines = String[]
    dir_count = 0
    file_count = 0
    
    with_logger(logger) do
        @info "Generating directory structure" base=dir_path
        for (root, dirs, files) in walkdir(dir_path)
            if contains(root, ".git")
                continue
            end
            
            rel = relpath(root, dir_path)
            if rel == "."
                push!(lines, ".")
            else
                push!(lines, rel)
            end
            
            # Sort directories for consistent output
            for d in sort(dirs)
                push!(lines, "└── $d/")
                dir_count += 1
            end
            
            # Only include text files that aren't neglected
            text_files_in_dir = String[]
            for f in files
                fp = joinpath(root, f)
                if is_text_file(fp) && !should_neglect(fp, dir_path)
                    push!(text_files_in_dir, f)
                    file_count += 1
                end
            end
            
            # Sort files for consistent output
            for f in sort(text_files_in_dir)
                push!(lines, "    └── $f")
            end
        end
        @info "Directory structure generated" directories_included=dir_count text_files_included=file_count
    end
    return join(lines, "\n")
end

# Internal function for testing - resets global state
function _reset!()
    empty!(NEGLECT_PATHS)
    copy!(TEXT_FILE_EXTENSIONS, Set{String}([
    ".py",      # Python
    ".js",      # JavaScript
    ".ts",      # TypeScript
    ".jsx",     # React JSX
    ".tsx",     # TypeScript + JSX
    ".html",    # HTML
    ".htm",     # HTML (alternative)
    ".css",     # CSS
    ".scss",    # SASS
    ".sass",    # SASS
    ".java",    # Java
    ".cpp",     # C++
    ".cxx",     # C++
    ".cc",      # C++
    ".c",       # C
    ".h",       # C/C++ Header
    ".hpp",     # C++ Header
    ".go",      # Go
    ".rs",      # Rust
    ".rb",      # Ruby
    ".php",     # PHP
    ".swift",   # Swift
    ".kt",      # Kotlin
    ".kts",     # Kotlin Script
    ".cs",      # C#
    ".fs",      # F#
    ".fsx",     # F# Script
    ".scala",   # Scala
    ".sc",      # Scala Script
    ".pl",      # Perl
    ".pm",      # Perl Module
    ".t",       # Perl Test
    ".lua",     # Lua
    ".dart",    # Dart
    ".erl",     # Erlang
    ".hrl",     # Erlang Header
    ".ex",      # Elixir
    ".exs",     # Elixir Script
    ".clj",     # Clojure
    ".cljs",    # ClojureScript
    ".edn",     # Extensible Data Notation
    ".groovy",  # Groovy
    ".gvy",     # Groovy
    ".gy",      # Groovy
    ".gsh",     # Groovy Shell
    ".hs",      # Haskell
    ".lhs",     # Literate Haskell
    ".ml",      # OCaml / Standard ML
    ".mli",     # OCaml Interface
    ".v",       # Verilog
    ".sv",      # SystemVerilog
    ".svh",     # SystemVerilog Header
    ".vhdl",    # VHDL
    ".vhd",     # VHDL
    ".asm",     # Assembly
    ".s",       # Assembly (GAS)
    ".S",       # Preprocessed Assembly
    ".p",       # Pascal
    ".pas",     # Pascal
    ".d",       # D Language
    ".jl",      # Julia
    ".nim",     # Nim
    ".zig",     # Zig
    ".odin",    # Odin
    ".f",       # Fortran
    ".for",     # Fortran
    ".f90",     # Fortran 90
    ".f95",     # Fortran 95
    ".coffee",  # CoffeeScript
    ".ls",      # LiveScript
    ".elm",     # Elm
    ".r",       # R
    ".R",       # R script
    ".Rmd",     # R Markdown
    ".sql",     # SQL
    ".ddl",     # Data Definition Language
    ".dml",     # Data Manipulation Language
    ".prql",    # PRQL
    ".json",    # JSON
    ".jsonc",   # JSON with Comments
    ".xml",     # XML
    ".yml",     # YAML
    ".yaml",    # YAML
    ".toml",    # TOML
    ".ini",     # INI config
    ".cfg",     # Config
    ".conf",    # Config (Unix)
    ".env",     # Environment variables
    ".dotenv",  # Alternative .env name
    ".properties", # Java Properties
    ".plist",   # Property List (Apple)
    ".reg",     # Windows Registry (text-based)
    ".desktop", # Linux Desktop Entry
    ".service", # systemd service (text)
    ".sh",      # Shell script
    ".bash",    # Bash script
    ".zsh",     # Zsh script
    ".fish",    # Fish shell
    ".ps1",     # PowerShell
    ".bat",     # Windows Batch
    ".cmd",     # CMD script
    ".vbs",     # VBScript
    ".ahk",     # AutoHotkey
    ".md",      # Markdown
    ".markdown",# Markdown
    ".adoc",    # AsciiDoc
    ".rst",     # reStructuredText
    ".txt",     # Plain text
    ".log",     # Log file
    ".tex",     # LaTeX
    ".sty",     # LaTeX Style
    ".bib",     # BibTeX
    ".cmake",   # CMake script
    ".gradle",  # Gradle build
    ".podspec", # CocoaPods spec
    ".gemspec", # Ruby gem spec
    ".prettierrc",  # Prettier config
    ".eslintrc",    # ESLint config
    ".babelrc",     # Babel config
    ".tf",          # Terraform
    ".tfvars",      # Terraform variables
    ".hcl",         # HCL (Terraform, Vault)
    ".wat",         # WebAssembly Text Format
    ".rss",         # RSS feed
    ".atom",        # Atom feed
    ".csv",         # CSV
    ".tsv",         # TSV
    ".ndjson",      # Newline-delimited JSON
    ".geojson",     # GeoJSON
    ".proto",       # Protocol Buffers
])
)
    return nothing
end