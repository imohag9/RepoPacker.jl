
"""
    estimate_token_count(content::String)

Estimate token count using the simple heuristic: `length(content) ÷ 4`.
This approximates GPT-style tokenizers for English-like code/text.

# Returns
- Estimated token count as `Int`
"""
function estimate_token_count(content::String)
    return length(content) ÷ 4
end

"""
    calculate_file_metrics(text_files::Vector{String}, base_dir::AbstractString)

Calculate metrics for a collection of text files.

# Returns
- Tuple containing:
  * total_chars: Total character count
  * total_tokens: Total token estimate
  * file_char_counts: Dict mapping file paths to character counts
  * file_token_counts: Dict mapping file paths to token estimates
"""
function calculate_file_metrics(text_files::Vector{String}, base_dir::AbstractString)
    file_char_counts = Dict{String, Int}()
    file_token_counts = Dict{String, Int}()
    total_chars = 0
    total_tokens = 0

    for fp in text_files
        rel_path = relpath(fp, base_dir)
        content = try
            String(read(fp))
        catch
            continue
        end
        
        char_count = length(content)
        token_count = estimate_token_count(content)
        
        file_char_counts[rel_path] = char_count
        file_token_counts[rel_path] = token_count
        
        total_chars += char_count
        total_tokens += token_count
    end
    
    return total_chars, total_tokens, file_char_counts, file_token_counts
end

"""
    get_top_files(file_token_counts::Dict{String, Int}, n::Int=5)

Get the top N files with the highest token counts.

# Returns
- Vector of tuples (file_path, token_count) sorted by token count descending
"""
function get_top_files(file_token_counts::Dict{String, Int}, n::Int=5)
    sorted_files = sort(collect(file_token_counts), by=x -> x[2], rev=true)
    return first(sorted_files, min(n, length(sorted_files)))
end