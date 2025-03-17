# MapLeaflet
# Place Map Viewer with Distance Calculation

This Shiny app lets you:
- **Upload a CSV file** with place names and their coordinates.
- **Select columns** corresponding to place names, latitude, longitude, and any additional variables to display as tooltips.
- **Visualize places** on a Leaflet map.
- **Select two markers** on the map by clicking them—the app calculates the geodesic ("as the crow flies") distance between these two markers using the `geosphere` package.
- **View results** in three tabs: a "Data" tab for the uploaded CSV preview, a "Map" tab for interactive mapping, and a "Distance" tab for the calculated distance.
- **Reset selections** to choose different markers.

## Files

- **dependencies.R**: Checks for and installs required packages, then loads them.
- **ui.R**: Contains the user interface code.
- **server.R**: Contains the server logic (data processing, marker selection, and distance calculation).
- **README.md**: This file.

## How to Run

1. **Clone or Download the Repository:**
   Make sure all files (`dependencies.R`, `ui.R`, `server.R`, and `README.md`) are in the same directory.

2. **Set Your Working Directory:**
   In R or RStudio, set your working directory to the folder containing these files. For example:
   ```r
   setwd("C:/Path/To/Your/Folder")
