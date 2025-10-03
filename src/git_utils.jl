

"""
    clone_and_pack(repo_url::AbstractString, output_file::AbstractString="repo.xml"; 
                   output_style::Symbol=:xml, temp_dir::AbstractString=tempname(), verbose::Bool=false)

Clone a GitHub repository and pack its text files into a file in the specified format.

# Arguments
- `repo_url`: URL of the Git repository to clone
- `output_file`: Output file path (default: "repo.xml")
- `output_style`: Format to use (`:xml`, `:json`, or `:markdown`)
- `temp_dir`: Temporary directory for cloning (default: auto-generated)
- `verbose`: Whether to enable detailed logging (default: false)

# Returns
- Path to the generated output file

# Examples
```julia
RepoPacker.clone_and_pack("https://github.com/username/repo.git", "output.xml")
```

# Errors
- Throws errors related to Git operations or file writing
"""
function clone_and_pack(repo_url::AbstractString, output_file::AbstractString="repo.xml";
                        output_style::Symbol=:xml, temp_dir::AbstractString=tempname(), verbose::Bool=false)
    logger = verbose ? ConsoleLogger(stderr, Logging.Info) : NullLogger()
    
    with_logger(logger) do
        @info "Starting clone and pack" url=repo_url output=output_file style=output_style
        mkpath(temp_dir)
        try
            @info "Cloning repository" url=repo_url path=temp_dir
            LibGit2.clone(repo_url, temp_dir)
            @info "Repository cloned successfully"
            pack_directory(temp_dir, output_file; output_style=output_style, verbose=verbose)
            return output_file
        finally
            rm(temp_dir, recursive=true, force=true)
            @debug "Temporary directory cleaned up" path=temp_dir
        end
    end
end

"""
    pack_directory(dir_path::AbstractString, output_file::AbstractString="repo.xml"; 
                   output_style::Symbol=:xml, verbose::Bool=false)

Pack the text files in a directory into a file in the specified format.

# Arguments
- `dir_path`: Directory path to pack
- `output_file`: Output file path (default: "repo.xml")
- `output_style`: Format to use (`:xml`, `:json`, or `:markdown`)
- `verbose`: Whether to enable detailed logging (default: false)

# Returns
- Path to the generated output file

# Examples
```julia
RepoPacker.pack_directory(".", "repo.xml")
```

# Errors
- Throws `ArgumentError` if directory doesn't exist
"""
function pack_directory(dir_path::AbstractString, output_file::AbstractString="repo.xml";
                        output_style::Symbol=:xml, verbose::Bool=false)
    if !isdir(dir_path)
        throw(ArgumentError("Directory does not exist: $dir_path"))
    end
    
    text_files = collect_text_files(dir_path; verbose=verbose)
    
    if isempty(text_files)
        # Minimal fallback
        if output_style == :json
            empty_json = JSON.json(Dict(
                "fileSummary" => Dict("purpose" => "No text files were found in the repository"),
                "files" => Dict{String, String}(),
                "metrics" => Dict("totalFiles" => 0, "totalCharacters" => 0, "totalTokens" => 0)
            ), 2)
            write(output_file, empty_json)
        elseif output_style == :markdown
            empty_md = """# Repository Packed by RepoPacker.jl
            
No text files were found in the repository.

## Metrics
- **Total Files**: 0
- **Total Characters**: 0
- **Estimated Tokens**: 0
"""
            write(output_file, empty_md)
        else
            header = """This file is a merged representation of the entire codebase, combined into a single document by RepoPacker.\nThe content has been processed where security check has been disabled.\n"""
            empty_xml = "<files><file_summary><purpose>No text files were found in the repository</purpose></file_summary></files>"
            write(output_file, header * empty_xml)
        end
        return output_file
    end
    
    content = if output_style == :json
        generate_json_content(text_files, dir_path; verbose=verbose)
    elseif output_style == :markdown
        generate_markdown_content(text_files, dir_path; verbose=verbose)
    elseif output_style == :xml
        generate_xml_content(text_files, dir_path; verbose=verbose)
    else
        throw(ArgumentError("Unsupported output_style: $output_style. Use :xml, :json, or :markdown."))
    end
    
    write(output_file, content)
    return output_file
end