# ============================================================================
# E-WASTE TREND ANALYSIS - MAIN EXECUTION SCRIPT
# ============================================================================
# 
# This script orchestrates the entire analysis pipeline:
# 1. Data import & exploration
# 2. Data cleaning & transformation
# 3. Statistical analysis
# 4. Visualization generation
#
# Run this script to execute the full analysis end-to-end.
# Or source individual scripts from the 'scripts/' folder for step-by-step execution.
#
# ============================================================================

start_time <- Sys.time()

cat("\n")
cat("╔════════════════════════════════════════════════════════════════════╗\n")
cat("║        E-WASTE TREND ANALYSIS: FULL PIPELINE EXECUTION             ║\n")
cat("║                   From clicks-to-waste                             ║\n")
cat("╚════════════════════════════════════════════════════════════════════╝\n")
cat("\nStarted at:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")

# ============================================================================
# STEP 1: DATA IMPORT
# ============================================================================
source("scripts/01_data_import.R")

# ============================================================================
# STEP 2: DATA CLEANING
# ============================================================================
source("scripts/02_data_cleaning.R")

# ============================================================================
# STEP 3: ANALYSIS
# ============================================================================
source("scripts/03_analysis.R")

# ============================================================================
# STEP 4: VISUALIZATION
# ============================================================================
source("scripts/04_visualization.R")

# ============================================================================
# SUMMARY
# ============================================================================

end_time <- Sys.time()
execution_time <- difftime(end_time, start_time, units = "secs")

cat("\n")
cat("╔════════════════════════════════════════════════════════════════════╗\n")
cat("║                    PIPELINE COMPLETE ✓                             ║\n")
cat("╚════════════════════════════════════════════════════════════════════╝\n")
cat("\nCompleted at:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Total execution time:", round(as.numeric(execution_time), 2), "seconds\n")
cat("\nOutput locations:\n")
cat("  • Cleaned data:  ", FILE_EWASTE_CLEAN, "\n")
cat("  • Tables:        ", PATH_OUTPUT_TABLES, "\n")
cat("  • Plots:         ", PATH_OUTPUT_PLOTS, "\n")
cat("\n")
