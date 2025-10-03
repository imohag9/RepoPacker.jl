

@testset "Basic Functionality" begin
    # Create a simple test directory
    test_dir = mktempdir()
    open(joinpath(test_dir, "test.jl"), "w") do io
        write(io, "println(\"Hello, World!\")")
    end
    
    # Test file collection
    files = RepoPacker.collect_text_files(test_dir)
    @test length(files) == 1
    @test contains(files[1], "test.jl")
    
    # Test directory structure
    structure = RepoPacker.get_directory_structure(test_dir)
    @test contains(structure, "test.jl")
    
    # Test XML generation
    xml_content = RepoPacker.generate_xml_content(files, test_dir)
    @test contains(xml_content, "<file path=\"test.jl\">")
    @test contains(xml_content, "Hello, World!")
    @test contains(xml_content, "<total_files>1</total_files>")
    
    # Test JSON generation
    json_content = RepoPacker.generate_json_content(files, test_dir)
    @test contains(json_content, "\"test.jl\"")
    @test contains(json_content, "Hello, World!")
    json_obj = JSON.parse(json_content)
    @test json_obj["metrics"]["totalFiles"] == 1
    
    # Test Markdown generation
    md_content = RepoPacker.generate_markdown_content(files, test_dir)
    @test contains(md_content, "### File: test.jl")
    @test contains(md_content, "Hello, World!")
    @test contains(md_content, "**Total Files**: 1")
    
    output_file = joinpath(test_dir, "basic.xml")
    output_xml = RepoPacker.pack_directory(test_dir, output_file)
    @test isfile(output_xml)
    @test filesize(output_xml) > 0
    rm(output_xml)
    
    output_file = joinpath(test_dir, "basic.json")
    output_file_json = RepoPacker.pack_directory(test_dir, output_file, output_style=:json)
    @test isfile(output_file_json)
    @test filesize(output_file_json) > 0
    rm(output_file_json)
    
    output_file = joinpath(test_dir, "basic.md")
    output_file_md = RepoPacker.pack_directory(test_dir, output_file, output_style=:markdown)
    @test isfile(output_file_md)
    @test filesize(output_file_md) > 0
    rm(output_file_md)
    # Cleanup
    rm(test_dir, recursive=true, force=true)
end