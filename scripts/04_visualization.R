# Step 4: Create visualizations
# ============================================================================

cat("\n=== STEP 4: VISUALIZATION ===\n")

# Load configuration and functions (if not already loaded)
if (!exists("PATH_OUTPUT_PLOTS")) {
  source("config.R")
  source("functions.R")
  library(tidyverse)
  library(scales)
}

# Load cleaned data and analysis results
cat("Loading data and analysis results...\n")
ewaste_clean <- read_csv(FILE_EWASTE_CLEAN) %>%
  mutate(
    country = as.factor(country),
    year = as.integer(year),
    e_waste_recycled = as.numeric(e_waste_recycled)
  )

yearly_avg <- read_csv(FILE_YEARLY_AVG)
country_stats <- read_csv(FILE_COUNTRY_STATS)

cat("✓ Data loaded\n")

# ============================================================================
# CREATE VISUALIZATIONS
# ============================================================================

cat("\nGenerating visualizations...\n\n")

# 1. Time Series Plot
cat("1. Creating time series plot...\n")
p1 <- plot_time_series(yearly_avg)
save_plot(p1, "01_time_series.png")

# 2. Top Countries Bar Chart
cat("2. Creating top countries bar chart...\n")
p2 <- plot_top_countries(ewaste_clean)
save_plot(p2, "02_top_countries.png")

# 3. Heatmap
cat("3. Creating heatmap...\n")
p3 <- plot_heatmap(ewaste_clean)
save_plot(p3, "03_heatmap.png")

# 4. Top vs Bottom Performers
cat("4. Creating top vs bottom performers plot...\n")
p4 <- plot_top_vs_bottom(ewaste_clean, country_stats, n = 5)
save_plot(p4, "04_top_vs_bottom.png")

cat("\n✓ All visualizations created and saved to:", PATH_OUTPUT_PLOTS, "\n")

cat("\n✓ Step 4 complete: Visualization finished\n")
