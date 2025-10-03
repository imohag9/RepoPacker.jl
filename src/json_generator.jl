
"""
    generate_json_content(text_files::Vector{String}, base_dir::AbstractString; verbose::Bool=false)

Generate repository content in Repomix-inspired JSON format.

# Returns
- String containing valid JSON with keys: `fileSummary`, `directoryStructure`, `files`, `metrics`
"""
function generate_json_content(text_files::Vector{String}, base_dir::AbstractString; verbose::Bool=false)
    logger = verbose ? ConsoleLogger(stderr, Logging.Info) : NullLogger()
    
    with_logger(logger) do
        @info "Generating JSON content" file_count=length(text_files)
    end

    # === fileSummary ===
    file_summary = Dict(
        "purpose" => "This file contains a packed representation of the entire repository's contents.\nIt is designed to be easily consumable by AI systems for analysis, code review,\nor other automated processes.",
        "fileFormat" => "The content is organized as follows:\n1. This summary section\n2. Repository information\n3. Directory structure\n4. Repository files (if enabled)\n5. Key-value mapping of file paths to contents",
        "usageGuidelines" => "- This file should be treated as read-only. Any changes should be made to the\n  original repository files, not this packed version.\n- When processing this file, use the file path to distinguish\n  between different files in the repository.\n- Be aware that this file may contain sensitive information. Handle it with\n  the same level of security as you would the original repository.",
        "notes" => "- Some files may have been excluded based on .gitignore rules and RepoPacker's configuration\n- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files\n- Files matching patterns in .gitignore are excluded\n- Files matching default ignore patterns are excluded\n- content may contain sensitive information"
    )

    # === directoryStructure ===
    dir_structure = get_directory_structure(base_dir; verbose=verbose)

    # === files + metrics ===
    total_chars, total_tokens, file_char_counts, file_token_counts = calculate_file_metrics(text_files, base_dir)

    files_dict = Dict{String, String}()
    for fp in text_files
        rel_path = relpath(fp, base_dir)
        content = try
            String(read(fp))
        catch e
            with_logger(verbose ? ConsoleLogger(stderr, Logging.Warn) : NullLogger()) do
                @warn "Failed to read file, skipping" path=fp error=string(e)
            end
            continue
        end
        files_dict[rel_path] = content
    end

    # Build final JSON structure
    result = Dict(
        "fileSummary" => file_summary,
        "directoryStructure" => dir_structure,
        "files" => files_dict,
        "metrics" => Dict(
            "totalFiles" => length(files_dict),
            "totalCharacters" => total_chars,
            "totalTokens" => total_tokens,
            "fileCharCounts" => file_char_counts,
            "fileTokenCounts" => file_token_counts
        )
    )

    return JSON.json(result, 2)  # Pretty-print with 2-space indent
end