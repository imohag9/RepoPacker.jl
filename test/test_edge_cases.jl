
@testset "Edge Cases" begin
    # Setup
    test_dir = mktempdir()

    # Create test files
    open(joinpath(test_dir, "test.jl"), "w") do io
        write(io, "module TestModule end")
    end

    # Create empty directory
    mkdir(joinpath(test_dir, "empty_dir"))

    # Create directory with no text files
    mkdir(joinpath(test_dir, "bin_dir"))
    open(joinpath(test_dir, "bin_dir", "binary.dat"), "w") do io
        write(io, rand(UInt8, 100))
    end

    # Create directory with special characters
    special_dir = joinpath(test_dir, "special@#\$%")
    mkdir(special_dir)
    open(joinpath(special_dir, "file.txt"), "w") do io
        write(io, "Special characters test")
    end

    # Test empty directory
    empty_dir = mktempdir()
    empty_files = RepoPacker.collect_text_files(empty_dir)
    @test isempty(empty_files)

    output_file = joinpath(empty_dir, "empty.xml")
    output_file_xml = RepoPacker.pack_directory(empty_dir, output_file)
    @test isfile(output_file_xml)

    @test contains(String(read(output_file_xml)), "No text files were found in the repository")
    rm(output_file_xml)

    output_file = joinpath(empty_dir, "empty.json")
    output_file_json = RepoPacker.pack_directory(
    empty_dir, output_file, output_style = :json)
    @test isfile(output_file_json)
    json_obj = JSON.parse(String(read(output_file_json)))
    @test json_obj["metrics"]["totalFiles"] == 0
    rm(output_file_json)

    output_file = joinpath(empty_dir, "empty.md")
    output_file_md = RepoPacker.pack_directory(
        empty_dir, output_file, output_style = :markdown)
    @test isfile(output_file_md)
    @test contains(
    String(read(output_file_md)), "No text files were found in the repository")
    rm(output_file_md)

    # Test directory with no text files
    no_text_files = RepoPacker.collect_text_files(joinpath(test_dir, "bin_dir"))
    @test isempty(no_text_files)

    # Test special characters in paths
    special_files = RepoPacker.collect_text_files(test_dir)
    @test any(contains.(special_files, "special@#\$%"))

    # Test very long path
    long_dir = test_dir
    for i in 1:10
        long_dir = joinpath(long_dir, "very_long_directory_name_" * string(i))
        mkdir(long_dir)
    end
    open(joinpath(long_dir, "long_path_test.jl"), "w") do io
        write(io, "println(\"Long path test\")")
    end

    long_files = RepoPacker.collect_text_files(test_dir)
    @test any(contains.(long_files, "long_path_test.jl"))

    # Test directory with many files
    many_files_dir = joinpath(test_dir, "many_files")
    mkdir(many_files_dir)
    for i in 1:100
        open(joinpath(many_files_dir, "file_$i.jl"), "w") do io
            write(io, "println($i)")
        end
    end

    many_files = RepoPacker.collect_text_files(test_dir)
    @test length(many_files) >= 101  # Original files + 100 new ones

    # Test file with non-UTF8 content
    RepoPacker.reset!()
    RepoPacker.add_extension(".bin")

    non_utf8_file = joinpath(test_dir, "non_utf8.bin")
    open(non_utf8_file, "w") do io
        # Write some non-UTF8 bytes
        write(io, [0xff, 0xfe, 0xfd])
    end

    files = RepoPacker.collect_text_files(test_dir)
    @test any(contains.(files, "non_utf8.bin"))



    # Test token counting
    token_file = joinpath(test_dir, "tokens.txt")
    content = "This is a test string with approximately 10 tokens."
    open(token_file, "w") do io
        write(io, content)
    end
    token_count = RepoPacker.estimate_token_count(content)
    @test token_count == length(content) ÷ 4

    # Cleanup
    rm(test_dir, recursive = true, force = true)
end