using Documenter, ClimaExplorer

makedocs(
    sitename = "ClimaExplorer",
    format = Documenter.HTML(),
    pages = [
        "Home" => "index.md",
        "API" => "man/data_loader.md"
    ]
)

deploydocs(
    repo = "github.com/HarshitNagpal29/Interactive-Climate-Variable-Explorer-with-Real-Time-Data-Slicing.git",
)