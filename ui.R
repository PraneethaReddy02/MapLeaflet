# ui.R
source("dependencies.R")

ui <- fluidPage(
  titlePanel("Place Map Viewer with Distance Calculation"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload CSV File", accept = ".csv"),
      # Dynamic UI for variable selection
      uiOutput("varselect_ui"),
      actionButton("reset_btn", "Reset Selection")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Data",
                 h3("Uploaded Data (First 10 Rows)"),
                 DTOutput("data_table")
        ),
        tabPanel("Map",
                 leafletOutput("map")
        ),
        tabPanel("Distance",
                 h3("Distance Calculation"),
                 verbatimTextOutput("distance_output")
        )
      )
    )
  )
)
