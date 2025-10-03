

"""
    generate_xml_content(text_files::Vector{String}, base_dir::AbstractString; verbose::Bool=false)

Generate XML content in Repomix format.

# Arguments
- `text_files`: Vector of text file paths to include
- `base_dir`: Base directory of the repository
- `verbose`: Whether to enable detailed logging (default: false)

# Returns
- String containing the XML content with header

# Examples
```julia
files = RepoPacker.collect_text_files(".")
xml_content = RepoPacker.generate_xml_content(files, ".")
```
"""
function generate_xml_content(text_files::Vector{String}, base_dir::AbstractString; verbose::Bool=false)
    logger = verbose ? ConsoleLogger(stderr, Logging.Info) : NullLogger()
    
    with_logger(logger) do
        @info "Generating XML content" file_count=length(text_files)
    end
    
    root = XML.Element("files")
    # === file_summary section ===
    file_summary = XML.Element("file_summary")
    push!(XML.children(root), file_summary)
    
    purpose = XML.Element("purpose")
    push!(XML.children(purpose), XML.Text("This file contains a packed representation of the entire repository's contents.\nIt is designed to be easily consumable by AI systems for analysis, code review,\nor other automated processes."))
    push!(XML.children(file_summary), purpose)
    
    file_format = XML.Element("file_format")
    push!(XML.children(file_format), XML.Text("The content is organized as follows:\n1. This summary section\n2. Repository information\n3. Directory structure\n4. Repository files (if enabled)\n5. Multiple file entries, each consisting of:\n  - File path as an attribute\n  - Full contents of the file"))
    push!(XML.children(file_summary), file_format)
    
    usage_guidelines = XML.Element("usage_guidelines")
    push!(XML.children(usage_guidelines), XML.Text("- This file should be treated as read-only. Any changes should be made to the\n  original repository files, not this packed version.\n- When processing this file, use the file path to distinguish\n  between different files in the repository.\n- Be aware that this file may contain sensitive information. Handle it with\n  the same level of security as you would the original repository."))
    push!(XML.children(file_summary), usage_guidelines)
    
    # === metrics section ===
    total_chars, total_tokens, file_char_counts, file_token_counts = calculate_file_metrics(text_files, base_dir)
    
    metrics = XML.Element("metrics")
    push!(XML.children(metrics), XML.Element("total_files", string(length(text_files))))
    push!(XML.children(metrics), XML.Element("total_characters", string(total_chars)))
    push!(XML.children(metrics), XML.Element("total_tokens", string(total_tokens)))
    
    # Top files by token count
    top_files_elem = XML.Element("top_files")
    for (path, tokens) in get_top_files(file_token_counts)
        file_elem = XML.Element("file", path=path)
        push!(XML.children(file_elem), XML.Element("tokens", string(tokens)))
        push!(XML.children(top_files_elem), file_elem)
    end
    push!(XML.children(metrics), top_files_elem)
    push!(XML.children(file_summary), metrics)
    
    notes = XML.Element("notes")
    push!(XML.children(notes), XML.Text("- Some files may have been excluded based on .gitignore rules and Repomix's configuration\n- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files\n- Files matching patterns in .gitignore are excluded\n- Files matching default ignore patterns are excluded\n- Security check has been disabled - content may contain sensitive information\n- Files are sorted by Git change count (files with more changes are at the bottom)"))
    push!(XML.children(file_summary), notes)
    
    # === directory_structure section ===
    dir_struct = XML.Element("directory_structure")
    dir_text = get_directory_structure(base_dir; verbose=verbose)
    push!(XML.children(dir_struct), XML.Text(dir_text))
    push!(XML.children(root), dir_struct)
    
    # === file entries ===
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
        
        file_elem = XML.Element("file", path=rel_path)
        push!(XML.children(file_elem), XML.Text(content))
        push!(XML.children(root), file_elem)
    end
    
    xml_str = XML.write(root)
    header = """This file is a merged representation of the entire codebase, combined into a single document by Repomix.\nThe content has been processed where security check has been disabled.\n"""
    
    return header * xml_str
end