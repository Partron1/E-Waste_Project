# Configuration file for E-Waste Trend Analysis
# Paths, themes, and constants

# ============================================================================
# PROJECT PATHS
# ============================================================================
PATH_DATA <- "dataset"
PATH_OUTPUT <- "output"
PATH_OUTPUT_DATA <- file.path(PATH_OUTPUT, "data")
PATH_OUTPUT_PLOTS <- file.path(PATH_OUTPUT, "plots")
PATH_OUTPUT_TABLES <- file.path(PATH_OUTPUT, "tables")

# Create output directories if they don't exist
dir.create(PATH_OUTPUT, showWarnings = FALSE)
dir.create(PATH_OUTPUT_DATA, showWarnings = FALSE)
dir.create(PATH_OUTPUT_PLOTS, showWarnings = FALSE)
dir.create(PATH_OUTPUT_TABLES, showWarnings = FALSE)

# ============================================================================
# DATA FILE PATHS
# ============================================================================
FILE_EWASTE_RAW <- file.path(PATH_DATA, "ewaste_europe.csv")

# ============================================================================
# OUTPUT FILE NAMES
# ============================================================================
FILE_EWASTE_CLEAN <- file.path(PATH_OUTPUT_DATA, "ewaste_clean.csv")
FILE_YEARLY_AVG <- file.path(PATH_OUTPUT_TABLES, "yearly_avg.csv")
FILE_COUNTRY_STATS <- file.path(PATH_OUTPUT_TABLES, "country_stats.csv")

# ============================================================================
# VISUALIZATION THEMES & COLORS
# ============================================================================
# Primary color palette
COLOR_PRIMARY <- "#006837"  # Green (used in original plots)
COLOR_HEATMAP_LOW <- "#ffffcc"
COLOR_HEATMAP_HIGH <- "#006837"

# ggplot2 theme template
THEME_MINIMAL_CUSTOM <- function() {
  theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
      plot.subtitle = element_text(hjust = 0.5, size = 11),
      panel.grid.major.y = element_blank(),
      legend.position = "bottom"
    )
}

# ============================================================================
# PLOT EXPORT SETTINGS
# ============================================================================
PLOT_WIDTH <- 10
PLOT_HEIGHT <- 6
PLOT_DPI <- 300
