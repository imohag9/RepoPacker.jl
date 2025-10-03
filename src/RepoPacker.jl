module RepoPacker

using LibGit2
using XML
using JSON
using Logging
using Base.Filesystem


include("file_utils.jl")
include("token_utils.jl")
include("xml_generator.jl")
include("json_generator.jl")
include("markdown_generator.jl")
include("git_utils.jl")

export add_extension, neglect_path, 
    clone_and_pack, pack_directory,
    TEXT_FILE_EXTENSIONS

end # module
