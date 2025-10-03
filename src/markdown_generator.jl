
"""
    generate_markdown_content(text_files::Vector{String}, base_dir::AbstractString; verbose::Bool=false)

Generate repository content in Repomix-compatible Markdown format.
"""
function generate_markdown_content(text_files::Vector{String}, base_dir::AbstractString; verbose::Bool=false)
    logger = verbose ? ConsoleLogger(stderr, Logging.Info) : NullLogger()
    
    with_logger(logger) do
        @info "Generating Markdown content" file_count=length(text_files)
    end

    # === Header ===
    output_lines = String[]
    push!(output_lines, "# Repository Packed by RepoPacker.jl")
    push!(output_lines, "")
    push!(output_lines, "This file contains a packed representation of the entire repository's contents.")
    push!(output_lines, "It is designed to be easily consumable by AI systems for analysis, code review, or other automated processes.")
    push!(output_lines, "")

    # === Metrics ===
    total_chars, total_tokens, file_char_counts, file_token_counts = calculate_file_metrics(text_files, base_dir)

    push!(output_lines, "## Metrics")
    push!(output_lines, "- **Total Files**: $(length(text_files))")
    push!(output_lines, "- **Total Characters**: $total_chars")
    push!(output_lines, "- **Estimated Tokens**: $total_tokens")
    push!(output_lines, "")

    # Top files
    top_files = get_top_files(file_token_counts)
    if !isempty(top_files)
        push!(output_lines, "### Top Files by Token Count")
        for (path, tokens) in top_files
            push!(output_lines, "- `$path`: $tokens tokens")
        end
        push!(output_lines, "")
    end

    # === Directory Structure ===
    push!(output_lines, "## Directory Structure")
    dir_struct = get_directory_structure(base_dir; verbose=verbose)
    for line in split(dir_struct, '\n')
        push!(output_lines, "    $line")
    end
    push!(output_lines, "")

    # === File Contents ===
    push!(output_lines, "## Files")
    push!(output_lines, "")

    # Determine max backticks needed
    max_backticks = 3
    for fp in text_files
        content = try
            String(read(fp))
        catch
            continue
        end
        matches = collect(eachmatch(r"`+", content)) # Use collect(eachmatch(...))
        if !isempty(matches)
            max_backticks = max(max_backticks, maximum(length, matches) + 1)
        end
    end
    delim = "`"^max_backticks

    for fp in text_files
        rel_path = relpath(fp, base_dir)
        ext = splitext(rel_path)[2]
        lang = isempty(ext) ? "" : lstrip(ext, '.')
        content = try
            String(read(fp))
        catch
            "<Failed to read file>"
        end

        push!(output_lines, "### File: $rel_path")
        push!(output_lines, "")
        push!(output_lines, "$delim$lang")
        push!(output_lines, content)
        push!(output_lines, "$delim")
        push!(output_lines, "")
    end

    return join(output_lines, "\n")
end