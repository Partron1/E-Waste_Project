# Step 3: Analyze e-waste trends
# ============================================================================

cat("\n=== STEP 3: ANALYSIS ===\n")

# Load configuration and functions (if not already loaded)
if (!exists("PATH_DATA")) {
  source("config.R")
  source("functions.R")
  library(tidyverse)
}

# Load cleaned data
cat("Loading cleaned data...\n")
ewaste_clean <- read_csv(FILE_EWASTE_CLEAN) %>%
  mutate(
    country = as.factor(country),
    year = as.integer(year),
    e_waste_recycled = as.numeric(e_waste_recycled)
  )

cat("✓ Data loaded\n")

# ============================================================================
# YEARLY ANALYSIS
# ============================================================================

cat("\n--- EU Average by Year ---\n")
yearly_avg <- calculate_yearly_average(ewaste_clean)
print(yearly_avg)

cat("\nSaving yearly averages...\n")
write_csv(yearly_avg, FILE_YEARLY_AVG)
cat("✓ Saved:", FILE_YEARLY_AVG, "\n")

# ============================================================================
# COUNTRY PERFORMANCE ANALYSIS
# ============================================================================

cat("\n--- Country Performance Statistics ---\n")
country_stats <- calculate_country_stats(ewaste_clean)
print(country_stats)

cat("\nSaving country statistics...\n")
write_csv(country_stats, FILE_COUNTRY_STATS)
cat("✓ Saved:", FILE_COUNTRY_STATS, "\n")

# ============================================================================
# KEY METRICS
# ============================================================================

cat("\n--- Key Metrics ---\n")
cat("Overall EU Average (2008-2018):", round(mean(ewaste_clean$e_waste_recycled), 1), "%\n")
cat("Starting rate (2008):", yearly_avg$avg_ewaste[1], "%\n")
cat("Ending rate (2018):", yearly_avg$avg_ewaste[nrow(yearly_avg)], "%\n")
cat("Total improvement:", yearly_avg$avg_ewaste[nrow(yearly_avg)] - yearly_avg$avg_ewaste[1], "%\n")

cat("\nTop 3 countries (avg rate):\n")
print(head(country_stats, 3))

cat("\nBottom 3 countries (avg rate):\n")
print(tail(country_stats, 3))

cat("\n✓ Step 3 complete: Analysis finished\n")
