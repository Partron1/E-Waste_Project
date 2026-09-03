# Step 2: Clean and transform e-waste data
# ============================================================================

cat("\n=== STEP 2: DATA CLEANING ===\n")

# Load configuration and functions (if not already loaded)
if (!exists("PATH_DATA")) {
  source("config.R")
  source("functions.R")
  library(tidyverse)
  library(janitor)
}

cat("\nImporting raw data...\n")
ewaste_df <- read_csv(FILE_EWASTE_RAW)

# Clean the data using helper function
cat("Cleaning data:\n")
cat("  - Dropping irrelevant columns\n")
cat("  - Converting wide to long format\n")
cat("  - Removing NAs\n")
cat("  - Formatting columns\n")

ewaste_clean <- clean_ewaste_data(ewaste_df)

cat("✓ Data cleaned successfully\n")
cat("  New dimensions:", nrow(ewaste_clean), "rows ×", ncol(ewaste_clean), "columns\n")

# Examine cleaned data
cat("\n--- Cleaned data summary ---\n")
print(summary(ewaste_clean))

cat("\n--- Records per country ---\n")
print(table(ewaste_clean$country))

cat("\n--- Data structure ---\n")
glimpse(ewaste_clean)

# Save cleaned data
cat("\nSaving cleaned data...\n")
write_csv(ewaste_clean, FILE_EWASTE_CLEAN)
cat("✓ Saved:", FILE_EWASTE_CLEAN, "\n")

cat("\n✓ Step 2 complete: Data cleaning finished\n")
