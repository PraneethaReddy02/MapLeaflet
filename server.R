# server.R
source("dependencies.R")

server <- function(input, output, session) {
  
  # Reactive expression to read the uploaded CSV file.
  map_data <- reactive({
    req(input$file)
    read.csv(input$file$datapath, stringsAsFactors = FALSE)
  })
  
  # Generate dynamic UI for selecting columns.
  output$varselect_ui <- renderUI({
    req(map_data())
    cols <- names(map_data())
    tagList(
      selectInput("place_col", "Select Place Column", choices = cols, selected = cols[1]),
      selectInput("lat_col", "Select Latitude Column", choices = cols, selected = cols[2]),
      selectInput("lon_col", "Select Longitude Column", choices = cols, selected = cols[3]),
      selectizeInput("tooltip_vars", "Select Tooltip Variables (Optional)",
                     choices = cols, multiple = TRUE)
    )
  })
  
  # Display the first 10 rows of the uploaded data.
  output$data_table <- renderDT({
    req(map_data())
    datatable(head(map_data(), 10))
  })
  
  # Reactive value to store selected markers.
  selected_markers <- reactiveVal(list())
  
  # Render the Leaflet map with markers.
  output$map <- renderLeaflet({
    req(map_data(), input$place_col, input$lat_col, input$lon_col)
    df <- map_data() %>%
      mutate(
        lat = as.numeric(.data[[input$lat_col]]),
        lon = as.numeric(.data[[input$lon_col]]),
        place = as.character(.data[[input$place_col]])
      ) %>%
      filter(!is.na(lat) & !is.na(lon))
    
    # Build tooltip text using selected variables.
    if (!is.null(input$tooltip_vars) && length(input$tooltip_vars) > 0) {
      df <- df %>%
        mutate(tooltip = apply(select(., one_of(input$tooltip_vars)), 1, function(x) {
          paste(paste(names(x), x, sep = ": "), collapse = "<br>")
        }))
    } else {
      df$tooltip <- df$place
    }
    
    leaflet(df) %>%
      addTiles() %>%
      addMarkers(lng = ~lon, lat = ~lat, layerId = ~place,
                 label = ~lapply(tooltip, HTML))
  })
  
  # Observe marker clicks to capture selections.
  observeEvent(input$map_marker_click, {
    req(map_data())
    
    # Get click coordinates.
    click <- input$map_marker_click
    if (is.null(click)) return()
    
    # Obtain the dataset used in the map.
    df <- map_data() %>%
      mutate(
        lat = as.numeric(.data[[input$lat_col]]),
        lon = as.numeric(.data[[input$lon_col]]),
        place = as.character(.data[[input$place_col]])
      ) %>%
      filter(!is.na(lat) & !is.na(lon))
    
    # Calculate Euclidean distances from the click to all markers.
    df <- df %>% mutate(dist = sqrt((lat - click$lat)^2 + (lon - click$lng)^2))
    closest_marker <- df %>% filter(dist == min(dist)) %>% slice(1)
    marker_info <- list(
      place = closest_marker$place,
      lat = closest_marker$lat,
      lon = closest_marker$lon
    )
    
    current_selection <- selected_markers()
    # If two markers are already selected, warn and exit.
    if (length(current_selection) >= 2) {
      showNotification("Two markers already selected. Please reset selection to choose new markers.", type = "warning")
      return()
    }
    
    # Prevent duplicate selection.
    if (any(sapply(current_selection, function(x) x$place) == marker_info$place)) {
      showNotification("Marker already selected. Choose a different marker.", type = "warning")
      return()
    }
    
    # Append the new marker.
    current_selection <- append(current_selection, list(marker_info))
    selected_markers(current_selection)
    
    if (length(current_selection) == 1) {
      showNotification("Select the second marker.", type = "message")
    } else if (length(current_selection) == 2) {
      showNotification("Two markers selected—distance calculated.", type = "message")
    }
  })
  
  # Reset button clears the selection.
  observeEvent(input$reset_btn, {
    selected_markers(list())
    showNotification("Selection reset, please start over.", type = "message")
  })
  
  # Calculate and display the distance between two selected markers.
  output$distance_output <- renderText({
    markers <- selected_markers()
    if (length(markers) < 2) {
      return("Please select two markers on the map to calculate the distance.")
    }
    p1 <- markers[[1]]
    p2 <- markers[[2]]
    # Calculate geodesic distance (meters) using distGeo().
    distance_m <- distGeo(c(p1$lon, p1$lat), c(p2$lon, p2$lat))
    distance_km <- distance_m / 1000
    paste0("Distance between ", p1$place, " and ", p2$place, ": ", sprintf("%.2f", distance_km), " km")
  })
}

# Do NOT call shinyApp() here in a multi-file app.
