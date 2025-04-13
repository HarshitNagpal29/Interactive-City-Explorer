# src/app.jl
module App

using Bonito, WGLMakie
using ..DataLoader: load_netcdf
using ..Visualization: create_heatmap, create_3d_surface

"""
    run_app(; port=8080)

Start the Bonito web server with interactive dashboard.
"""
function run_app(; port=8080)
    WGLMakie.activate!()
    
    # Load data
    data = load_netcdf("data/sample_data.nc")

    # Create app
    app = Bonito.App() do session::Bonito.Session
        # Create mode dropdown
        mode = Observable("2D Heatmap") # Default mode

        dropdown = Bonito.Dropdown(
            ["2D Heatmap", "3D Surface"]
        )
        on(dropdown.value) do value
            mode[] = value
        end
        
        # Time slider
        time_slider = Bonito.Slider(1:length(data.time), 
            startvalue=1,
            class="slider"
        )

        # Altitude slider
        alt_slider = Bonito.Slider(1:length(data.alt), 
            startvalue=1,
            class="slider"
        )

        
        # Reactive plot - Keep using @lift as it handles Makie updates well
        # Access .value explicitly here
        fig = @lift begin
            current_mode = $mode
            current_time = $time_slider
            current_alt = $alt_slider
            if current_mode == "2D Heatmap"
                create_heatmap(data; time_idx=current_time, alt_idx=current_alt)
            else
                create_3d_surface(data; time_idx=current_time, alt_idx=current_alt)
            end
        end
        # UI layout
        Bonito.DOM.div(
            Bonito.DOM.style("""
                .container { padding: 20px; font-family: Arial; }
                .title { color: #2c3e50; }
                .slider { width: 300px; margin: 10px; }
                .label { margin: 5px 0; }
                .controls { margin-bottom: 20px; }
                .webgl-canvas { width: 100% !important; height: 600px !important; }
                .mode-selector option { padding: 5px;}
                .debug-info { color: #666; font-style: italic; margin: 5px 0; } 
            """),
            Bonito.DOM.h1("ClimaExplorer", class="title"),
            mode, # Add the static label element
            Bonito.DOM.div(
                Bonito.DOM.p("Visualization:", class="label"),
                dropdown,
                Bonito.DOM.p("Time:", class="label"),
                time_slider,
                Bonito.DOM.p("Altitude:", class="label"),
                alt_slider,
                class="controls"
            ),
            fig,
            class="container"
        )
    end

    # Start server
    server = Bonito.Server(app, "0.0.0.0", port)
    println("Server running at http://localhost:$port")
    wait(server)
end

end # module