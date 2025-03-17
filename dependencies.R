# dependencies.R

# List of required packages
required_packages <- c("shiny", "leaflet", "geosphere", "dplyr", "DT")

# Check and install any missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(new_packages)) {
  install.packages(new_packages)
}

# Load all required packages
lapply(required_packages, library, character.only = TRUE)
