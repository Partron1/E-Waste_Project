# Step 1: Load and preview raw e-waste data
# ============================================================================

cat("\n=== STEP 1: DATA IMPORT ===\n")

# Load packages
library(tidyverse)
library(skimr)
library(janitor)
library(scales)
library(knitr)

cat("Packages loaded\n")

# Load configuration and functions
source("config.R")
source("functions.R")

cat("Config and functions sourced\n")

# Import dataset
cat("\nImporting data from:", FILE_EWASTE_RAW, "\n")
ewaste_df <- read_csv(FILE_EWASTE_RAW)

cat("✓ Data imported successfully\n")
cat("  Dimensions:", nrow(ewaste_df), "rows ×", ncol(ewaste_df), "columns\n")

# Preview first few rows
cat("\n--- First few rows ---\n")
print(head(ewaste_df))

# Check for missing values
cat("\n--- Missing values per column ---\n")
missing_values <- colSums(is.na(ewaste_df))
print(missing_values[missing_values > 0])
if (all(missing_values == 0)) cat("No missing values found\n")

# Examine data structure
cat("\n--- Data structure ---\n")
glimpse(ewaste_df)

# Examine column names
cat("\n--- Column names ---\n")
print(colnames(ewaste_df))

# Detail dataset summary
cat("\n--- Detailed summary ---\n")
skim_without_charts(ewaste_df)

cat("\n✓ Step 1 complete: Data import and preview finished\n")
