module DataLoader

using NetCDF, Zarr
using NCDatasets

"""
    load_netcdf(path::String) -> NamedTuple

Load NetCDF dataset into a NamedTuple with keys `lat`, `lon`, `alt`, `time`, `temp`.
"""
function load_netcdf(path::String)
    if !isfile(path)
        error("File $path not found.")
    end

    # Use NCDatasets.Dataset to open the file
    ds = Dataset(path, "r") # Open in read mode ("r")
    try
        # Access variables using NCDatasets syntax (ds[varname][:])
        data = (
            lat = ds["lat"][:], 
            lon = ds["lon"][:],
            alt = ds["alt"][:],
            time = ds["time"][:],
            temp = ds["temp"][:,:,:,:]
        )
        return data
    finally
        # Ensure the dataset is closed even if errors occur
        close(ds)
    end
end
"""
    generate_sample_data(path="data/sample_data.nc")

Generate synthetic climate data for testing.
"""
function generate_sample_data(path=nothing)
    # Default path relative to the project root (assuming src/data_loader.jl)
    if isnothing(path)
        project_root = dirname(@__DIR__) # Assumes src/data_loader.jl
        path = joinpath(project_root, "data", "sample_data.nc")
    end
    
    @info "Will create sample data at: $path"
    
    data_dir = dirname(path)

    # --- Define data generation outside the try block ---
    lat = collect(-90.0:5.0:90.0)   # 37 points
    lon = collect(-180.0:5.0:180.0)  # 73 points
    alt = collect(1:5)               # 5 levels
    time = collect(1:12)             # 12 months
    temp = randn(length(lat), length(lon), length(alt), length(time))
    # --- End data generation ---
    
    try
        # Create directory if needed
        if !isdir(data_dir)
            @info "Creating directory: $data_dir"
            mkpath(data_dir)
        end
        
        # Test write permissions (optional, but good practice)
        test_path = joinpath(data_dir, "test_write_permission.txt")
        try 
            open(test_path, "w") do io
                write(io, "test")
            end
            rm(test_path)
            @info "Successfully verified write permissions at: $data_dir"
        catch perm_error
            @error "Cannot write to directory: $data_dir" exception=(perm_error, catch_backtrace())
            error("Write permission error for $data_dir")
        end

        # Remove existing file before creating a new one
        if isfile(path)
            rm(path)
        end
        
        # Use NCDatasets API: Define dimensions, define variables, then assign data
        ds = Dataset(path, "c")
        
        # Define dimensions
        ds.dim["lat"] = length(lat)
        ds.dim["lon"] = length(lon)
        ds.dim["alt"] = length(alt)
        ds.dim["time"] = length(time)
        
        # --- Define variables using defVar ---
        vlat = defVar(ds, "lat", Float64, ("lat",))
        vlon = defVar(ds, "lon", Float64, ("lon",))
        valt = defVar(ds, "alt", Int32, ("alt",))
        vtime = defVar(ds, "time", Int32, ("time",))
        vtemp = defVar(ds, "temp", Float64, ("lat", "lon", "alt", "time"))
        # --- End variable definition ---

        # --- Assign data to the *variable objects* ---
        vlat[:] = lat
        vlon[:] = lon
        valt[:] = alt
        vtime[:] = time
        vtemp[:,:,:,:] = temp
        # --- End data assignment ---
        
        # Close the dataset
        close(ds)
        
        @info "Successfully saved NetCDF file at: $path"
        return path
    catch e
        @error "Error creating NetCDF file" exception=(e, catch_backtrace())
        # Fallback CSV creation removed for simplicity, assuming NetCDF is the goal
        error("Failed to create NetCDF file at $path") 
    end
end

end # module