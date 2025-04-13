using Test
using ClimaExplorer.DataLoader: load_netcdf, generate_sample_data

@testset "DataLoader" begin
    # Generate test data
    test_path = "data/test_sample.nc"
    generate_sample_data(test_path)

    # Load data
    data = load_netcdf(test_path)

    # Validate dimensions
    @test length(data.lat) == 37
    @test length(data.lon) == 73
    @test length(data.alt) == 5
    @test length(data.time) == 12
    @test size(data.temp) == (37, 73, 5, 12)

    # Cleanup
    rm(test_path)
end