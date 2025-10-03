

@testset "Metrics" begin
    # Create a test directory
    test_dir = mktempdir()
    
    # Create test files with known content
    open(joinpath(test_dir, "small.txt"), "w") do io
        write(io, "Small file")
    end
    
    open(joinpath(test_dir, "medium.txt"), "w") do io
        write(io, "This is a medium-sized file with more content.")
    end
    
    open(joinpath(test_dir, "large.txt"), "w") do io
        write(io, "This is a large file with even more content to test token counting."^2)
    end
    
    # Calculate expected metrics
    small_content = "Small file"
    medium_content = "This is a medium-sized file with more content."
    large_content = "This is a large file with even more content to test token counting."^2
    
    small_chars = length(small_content)
    medium_chars = length(medium_content)
    large_chars = length(large_content)
    
    small_tokens = small_chars ÷ 4
    medium_tokens = medium_chars ÷ 4
    large_tokens = large_chars ÷ 4
    
    total_files = 3
    total_chars = small_chars + medium_chars + large_chars
    total_tokens = small_tokens + medium_tokens + large_tokens
    
    # Collect files
    files = RepoPacker.collect_text_files(test_dir)
    @test length(files) == 3
    
    # Test XML metrics
    xml_content = RepoPacker.generate_xml_content(files, test_dir)
    @test contains(xml_content, "<total_files>$total_files</total_files>")
    @test contains(xml_content, "<total_characters>$total_chars</total_characters>")
    @test contains(xml_content, "<total_tokens>$total_tokens</total_tokens>")
    
    # Test JSON metrics
    json_content = RepoPacker.generate_json_content(files, test_dir)
    json_obj = JSON.parse(json_content)
    @test json_obj["metrics"]["totalFiles"] == total_files
    @test json_obj["metrics"]["totalCharacters"] == total_chars
    @test json_obj["metrics"]["totalTokens"] == total_tokens
    
    # Verify individual file metrics
    @test json_obj["metrics"]["fileCharCounts"]["small.txt"] == small_chars
    @test json_obj["metrics"]["fileTokenCounts"]["small.txt"] == small_tokens
    @test json_obj["metrics"]["fileCharCounts"]["medium.txt"] == medium_chars
    @test json_obj["metrics"]["fileTokenCounts"]["medium.txt"] == medium_tokens
    @test json_obj["metrics"]["fileCharCounts"]["large.txt"] == large_chars
    @test json_obj["metrics"]["fileTokenCounts"]["large.txt"] == large_tokens
    
    # Test Markdown metrics
    md_content = RepoPacker.generate_markdown_content(files, test_dir)
    @test contains(md_content, "**Total Files**: $total_files")
    @test contains(md_content, "**Total Characters**: $total_chars")
    @test contains(md_content, "**Estimated Tokens**: $total_tokens")
    
    # Verify top files ordering (large should be first)
    top_files_section = split(md_content, "### Top Files by Token Count")[2]
    top_files = split(top_files_section, "\n")[2:4]  # Get the top 3 lines
    @test contains(top_files[1], "large.txt")
    @test contains(top_files[2], "medium.txt")
    @test contains(top_files[3], "small.txt")
    
    # Test token counting function directly
    @test RepoPacker.estimate_token_count("abc") == 0  # 3 ÷ 4 = 0.75 → 0
    @test RepoPacker.estimate_token_count("abcd") == 1  # 4 ÷ 4 = 1
    @test RepoPacker.estimate_token_count("abcdefgh") == 2  # 8 ÷ 4 = 2
    
    # Cleanup
    rm(test_dir, recursive=true, force=true)
end