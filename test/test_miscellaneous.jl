const TEST_DIR = mktempdir()
cd(TEST_DIR)

# Setup test files
function setup_test_files()
    # Create directory structure
    mkdir("src")
    mkdir("test")
    mkdir("docs")
    mkdir("data")
    mkdir("config")

    # Create test files
    open("src/RepoPacker.jl", "w") do io
        write(io, "module RepoPacker\nexport pack_directory\nend")
    end

    open("src/utils.jl", "w") do io
        write(io, "function helper() return true end")
    end

    open("test/runtests.jl", "w") do io
        write(io, "using Test\n@test true")
    end

    open("docs/README.md", "w") do io
        write(io, "# Documentation\n\nThis is a test documentation file.")
    end

    open("config/settings.toml", "w") do io
        write(io, "[settings]\nvalue = 42")
    end

    # Create binary file (not included)
    open("data/binary.dat", "w") do io
        write(io, rand(UInt8, 100))
    end

    # Create .git directory (should be skipped)
    mkdir(joinpath("src", ".git"))
    open(joinpath("src", ".git", "config"), "w") do io
        write(io, "[core]\nrepositoryformatversion = 0")
    end

    # Create a hidden file
    open(".env", "w") do io
        write(io, "SECRET_KEY=12345")
    end

    # Create a custom extension file
    open("script.r", "w") do io
        write(io, "# R script\nx <- 1:10")
    end

    # Create a git repository
    LibGit2.init(TEST_DIR)
end

# Cleanup test files
function cleanup_test_files()
    try
        rm(TEST_DIR; recursive = true, force = true)
    catch
        # Ignore errors
    end
end

# Run all tests
@testset "RepoPacker.jl" begin
    @testset "Basic Setup" begin
        setup_test_files()

        # Verify directory structure
        @test isdir("src")
        @test isdir("test")
        @test isfile("src/RepoPacker.jl")
        @test isfile("docs/README.md")
    end

    @testset "File Collection" begin
        # Test basic file collection
        files = RepoPacker.collect_text_files(TEST_DIR)
        @test length(files) >= 5  # Should include .jl, .md, .toml files

        # Test with verbose logging
        files_verbose = RepoPacker.collect_text_files(TEST_DIR; verbose = true)
        @test files == files_verbose

        # Test .git directory is skipped
        @test !any(contains.(files, ".git"))

        # Test is_text_file
        @test RepoPacker.is_text_file("src/RepoPacker.jl")
        @test RepoPacker.is_text_file("docs/README.md")
        @test !RepoPacker.is_text_file("data/binary.dat")
    end

    @testset "Path Exclusion" begin
        # Reset state
        RepoPacker._reset!()

        # Test neglect_path
        RepoPacker.neglect_path("test/")
        files = RepoPacker.collect_text_files(TEST_DIR)
        @test !any(contains.(files, "test/runtests.jl"))

        # Test neglect hidden files
        RepoPacker.neglect_path(".env")
        files = RepoPacker.collect_text_files(TEST_DIR)
        @test !any(contains.(files, ".env"))

        # Test multiple neglect paths
        RepoPacker.neglect_path("docs/")
        RepoPacker.neglect_path("config/")
        files = RepoPacker.collect_text_files(TEST_DIR)
        @test !any(contains.(files, "docs/"))
        @test !any(contains.(files, "config/"))
    end

    @testset "Custom Extensions" begin
        # Reset state
        RepoPacker._reset!()

        # Test custom extension
        @test !RepoPacker.is_text_file("script.abc")
        RepoPacker.add_extension(".abc")
        @test RepoPacker.is_text_file("script.abc")
        open("test.abc", "w") do io
            write(io, "test")
        end
        # Test collecting with custom extension
        files = RepoPacker.collect_text_files(TEST_DIR)

        @test any(endswith.(files, ".abc"))
    end

    @testset "Directory Structure" begin
        # Test directory structure generation
        structure = RepoPacker.get_directory_structure(TEST_DIR)
        @test contains(structure, "src/")
        @test contains(structure, "    └── RepoPacker.jl")
        @test contains(structure, "docs/")
        @test contains(structure, "    └── README.md")
        @test contains(structure, ".git")
    end

    @testset "Token Counting" begin
        # Test token estimation
        content = "This is a test string with approximately 12 tokens."
        @test RepoPacker.estimate_token_count(content) ≈ length(content) ÷ 4

        # Test with actual file
        open("token_test.txt", "w") do io
            write(io, content)
        end
        char_count = length(content)
        token_count = RepoPacker.estimate_token_count(content)
        @test token_count == char_count ÷ 4
    end

    @testset "XML Generation with Metrics" begin
        # Test XML content generation
        files = RepoPacker.collect_text_files(TEST_DIR)
        xml_content = RepoPacker.generate_xml_content(files, TEST_DIR)

        # Check basic structure
        @test contains(xml_content, "<files>")
        @test contains(xml_content, "<file_summary>")
        @test contains(xml_content, "<directory_structure>")
        @test contains(xml_content, "<file path=\"src/RepoPacker.jl\">")
        @test !contains(xml_content, "<file path=\"data/binary.dat\">")

        # Check metrics
        @test contains(xml_content, "<total_files>")
        @test contains(xml_content, "<total_characters>")
        @test contains(xml_content, "<total_tokens>")
        @test contains(xml_content, "<top_files>")

        # Test with neglected paths
        RepoPacker._reset!()
        RepoPacker.neglect_path("test/")
        files = RepoPacker.collect_text_files(TEST_DIR)
        xml_content = RepoPacker.generate_xml_content(files, TEST_DIR)
        @test !contains(xml_content, "test/runtests.jl")
    end

    @testset "JSON Generation with Metrics" begin
        # Test JSON content generation
        files = RepoPacker.collect_text_files(TEST_DIR)
        json_content = RepoPacker.generate_json_content(files, TEST_DIR)

        # Check basic structure
        @test contains(json_content, "\"fileSummary\":")
        @test contains(json_content, "\"directoryStructure\":")
        @test contains(json_content, "\"files\":")
        @test contains(json_content, "\"metrics\":")

        # Check metrics
        @test contains(json_content, "\"totalFiles\":")
        @test contains(json_content, "\"totalCharacters\":")
        @test contains(json_content, "\"totalTokens\":")
        @test contains(json_content, "\"fileCharCounts\":")
        @test contains(json_content, "\"fileTokenCounts\":")

        # Parse JSON to verify structure
        json_obj = JSON.parse(json_content)
        @test haskey(json_obj, "fileSummary")
        @test haskey(json_obj, "directoryStructure")
        @test haskey(json_obj, "files")
        @test haskey(json_obj, "metrics")
        @test haskey(json_obj["metrics"], "totalFiles")
        @test haskey(json_obj["metrics"], "totalCharacters")
        @test haskey(json_obj["metrics"], "totalTokens")
    end

    @testset "Markdown Generation" begin
        # Test Markdown content generation
        files = RepoPacker.collect_text_files(TEST_DIR)
        md_content = RepoPacker.generate_markdown_content(files, TEST_DIR)

        # Check basic structure
        @test contains(md_content, "# Repository Packed by RepoPacker.jl")
        @test contains(md_content, "## Metrics")
        @test contains(md_content, "## Directory Structure")
        @test contains(md_content, "## Files")
        @test contains(md_content, "### File: src/RepoPacker.jl")

        # Check metrics
        @test contains(md_content, "**Total Files**:")
        @test contains(md_content, "**Total Characters**:")
        @test contains(md_content, "**Estimated Tokens**:")
        @test contains(md_content, "### Top Files by Token Count")
    end

    @testset "Packing Operations" begin
        # Test pack_directory with XML
        output_file = RepoPacker.pack_directory(TEST_DIR, "repo.xml")
        @test isfile(output_file)
        @test filesize(output_file) > 0
        xml_content = String(read(output_file))
        @test contains(xml_content, "<files>")

        # Test pack_directory with JSON
        output_file_json = RepoPacker.pack_directory(
            TEST_DIR, "repo.json", output_style = :json)
        @test isfile(output_file_json)
        @test filesize(output_file_json) > 0
        json_content = String(read(output_file_json))
        @test contains(json_content, "\"fileSummary\":")

        # Test pack_directory with Markdown
        output_file_md = RepoPacker.pack_directory(
            TEST_DIR, "repo.md", output_style = :markdown)
        @test isfile(output_file_md)
        @test filesize(output_file_md) > 0
        md_content = String(read(output_file_md))
        @test contains(md_content, "# Repository Packed by RepoPacker.jl")

        # Test with verbose logging
        output_file_verbose = RepoPacker.pack_directory(
            TEST_DIR, "repo_verbose.xml"; verbose = true)
        @test isfile(output_file_verbose)

        # Test empty directory
        empty_dir = mktempdir()
        output_file_empty = RepoPacker.pack_directory(empty_dir, "empty.xml")
        @test isfile(output_file_empty)
        @test contains(
            String(read(output_file_empty)), "No text files were found in the repository")

        # Test invalid directory
        @test_throws ArgumentError RepoPacker.pack_directory("nonexistent_dir")
    end

    @testset "Git Repository Operations" begin
        # Create a temporary test repo
        test_repo = mktempdir()
        cd(test_repo)
        open("test_file.txt", "w") do io
            write(io, "Test content")
        end
        repo = LibGit2.init(test_repo)
        LibGit2.add!(repo, "test_file.txt")
        LibGit2.commit(repo, "Initial commit")

        # Test clone_and_pack
        try
            # Create a local URL for testing
            local_url = "file://$(test_repo)"
            output_file = RepoPacker.clone_and_pack(local_url, "cloned_repo.xml")
            @test isfile(output_file)
            @test contains(String(read(output_file)), "test_file.txt")

            # Test JSON output
            output_file_json = RepoPacker.clone_and_pack(
                local_url, "cloned_repo.json", output_style = :json)
            @test isfile(output_file_json)
            @test contains(String(read(output_file_json)), "\"test_file.txt\"")

            # Test Markdown output
            output_file_md = RepoPacker.clone_and_pack(
                local_url, "cloned_repo.md", output_style = :markdown)
            @test isfile(output_file_md)
            @test contains(String(read(output_file_md)), "### File: test_file.txt")
        finally
            # Cleanup
            rm(test_repo, recursive = true, force = true)
        end
    end

    @testset "Edge Cases" begin
        # Test directory with special characters
        special_dir = joinpath(TEST_DIR, "special@#\$%")
        mkdir(special_dir)
        open(joinpath(special_dir, "file.txt"), "w") do io
            write(io, "Special characters test")
        end

        files = RepoPacker.collect_text_files(TEST_DIR)
        @test any(contains.(files, "special@#\$%"))

        # Test large file (should handle without issues)
        large_file = joinpath(TEST_DIR, "large.txt")
        open(large_file, "w") do io
            write(io, rand('a':'z', 10000))
        end
        @test RepoPacker.is_text_file(large_file)

        # Test file with non-UTF8 content (should skip with warning)
        non_utf8_file = joinpath(TEST_DIR, "non_utf8.bin")
        open(non_utf8_file, "w") do io
            # Write some non-UTF8 bytes
            write(io, [0xff, 0xfe, 0xfd])
        end

        # Reset state for this test
        RepoPacker._reset!()
        RepoPacker.add_extension(".bin")  # Make it try to read the file

        files = RepoPacker.collect_text_files(TEST_DIR)
        @test any(contains.(files, "non_utf8.bin"))

        # Test backticks in Markdown
        backtick_file = joinpath(TEST_DIR, "backticks.txt")
        open(backtick_file, "w") do io
            write(io, "This has ```` backticks ```")
        end
        md_content = RepoPacker.generate_markdown_content([backtick_file], TEST_DIR)
        @test contains(md_content, "````")
        @test !contains(md_content, "```````")
    end

  @testset "Metrics Validation" begin
    # Create a test file
    test_dir = mktempdir()
    content = "This is a test file with 10 tokens approximately."
    path = joinpath(test_dir, "testfile.txt")
    open(path, "w") do io
        write(io, content)
    end

    # Calculate expected metrics
    char_count = length(content)
    token_count = char_count ÷ 4

    # Test XML metrics
    xml_content = RepoPacker.generate_xml_content([path], test_dir)
    @test contains(xml_content, "<total_files>1</total_files>")
    @test contains(xml_content, "<total_characters>$char_count</total_characters>")
    @test contains(xml_content, "<total_tokens>$token_count</total_tokens>")

    # Test JSON metrics
    json_content = RepoPacker.generate_json_content([path], test_dir)
    json_obj = JSON.parse(json_content)
    @test json_obj["metrics"]["totalFiles"] == 1
    @test json_obj["metrics"]["totalCharacters"] == char_count
    @test json_obj["metrics"]["totalTokens"] == token_count

    # Test Markdown metrics
    md_content = RepoPacker.generate_markdown_content([path], test_dir)
    @test contains(md_content, "**Total Files**: 1")
    @test contains(md_content, "**Total Characters**: $char_count")
    @test contains(md_content, "**Estimated Tokens**: $token_count")

    # Cleanup
    rm(test_dir, recursive=true, force=true)
end
cleanup_test_files()
end