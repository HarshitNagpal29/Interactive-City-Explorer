# src/visualization.jl
module Visualization

using GLMakie, WGLMakie
using ..DataLoader: load_netcdf

export create_heatmap, create_3d_surface

"""
    create_heatmap(data; time_idx=1, alt_idx=1) -> Figure

Create a 2D heatmap of temperature at specified time and altitude.
"""
function create_heatmap(data; time_idx=1, alt_idx=1)
    fig = Figure(size=(800, 600))
    ax = Axis(fig[1, 1], 
        title="Temperature (t=$(data.time[time_idx]))",
        xlabel="Longitude",
        ylabel="Latitude"
    )

    # Extract slice: lat × lon × alt × time
    slice = data.temp[:, :, alt_idx, time_idx]

    # Plot
    heatmap!(ax, data.lon, data.lat, slice, colormap=:thermal)
    Colorbar(fig[1, 2], label="Temperature (°C)")

    return fig
end

"""
    create_3d_surface(data; time_idx=1, alt_idx=1) -> Figure

Create a 3D surface plot of temperature.
"""
function create_3d_surface(data; time_idx=1, alt_idx=1)
    fig = Figure(size=(800, 600))
    ax = Axis3(fig[1, 1], 
        title="3D Temperature (t=$(data.time[time_idx]))",
        xlabel="Longitude",
        ylabel="Latitude",
        zlabel="Temperature (°C)"
    )

    # Extract slice
    slice = data.temp[:, :, alt_idx, time_idx]  # 37 x 73

    # Create 2D grid from 1D lon/lat
    lon_grid = repeat(data.lon', length(data.lat), 1)  # 37 x 73
    lat_grid = repeat(data.lat, 1, length(data.lon))   # 37 x 73

    # Plot surface
    surface!(ax, lon_grid, lat_grid, slice, colormap=:thermal)
    Colorbar(fig[1, 2], label="Temperature (°C)")

    return fig
end
end # module Visualization