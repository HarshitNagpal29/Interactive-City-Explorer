module ClimaExplorer

# Include submodules
include("data_loader.jl")
include("visualization.jl")
include("app.jl")

export run_app

using .DataLoader: generate_sample_data
export generate_sample_data

end 