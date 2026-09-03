# Helper functions for E-Waste Trend Analysis
# Reusable utilities for data processing and visualization

# ============================================================================
# DATA CLEANING FUNCTIONS
# ============================================================================

#' Clean and transform raw e-waste data
#'
#' Converts wide-format data to long format, removes NAs, and formats columns.
#'
#' @param ewaste_df Raw dataframe from CSV
#' @return Cleaned dataframe in long format
#'
clean_ewaste_data <- function(ewaste_df) {
  ewaste_filter <- ewaste_df[, -c(12, 13, 19, 21, 27)]  # Drop irrelevant columns
  
  ewaste_clean <- ewaste_filter %>%
    pivot_longer(
      cols = !period,
      names_to = "country",
      values_to = "ewaste_recycled"
    ) %>%
    drop_na() %>%
    rename(year = period, e_waste_recycled = ewaste_recycled) %>%
    mutate(
      country = as.factor(country),
      year = as.integer(year),
      e_waste_recycled = as.numeric(e_waste_recycled)
    )
  
  return(ewaste_clean)
}

# ============================================================================
# ANALYSIS FUNCTIONS
# ============================================================================

#' Calculate yearly EU average e-waste recycling rate
#'
#' @param ewaste_clean Cleaned dataframe
#' @return Dataframe with year and avg_ewaste columns
#'
calculate_yearly_average <- function(ewaste_clean) {
  yearly_avg <- ewaste_clean %>%
    group_by(year) %>%
    summarise(avg_ewaste = mean(e_waste_recycled, na.rm = TRUE)) %>%
    mutate(avg_ewaste = round(avg_ewaste, 1))
  
  return(yearly_avg)
}

#' Calculate per-country performance statistics
#'
#' @param ewaste_clean Cleaned dataframe
#' @return Dataframe with country stats (avg, min, max, improvement)
#'
calculate_country_stats <- function(ewaste_clean) {
  country_stats <- ewaste_clean %>%
    group_by(country) %>%
    summarise(
      avg_rate = mean(e_waste_recycled),
      min_rate = min(e_waste_recycled),
      max_rate = max(e_waste_recycled),
      improvement = last(e_waste_recycled) - first(e_waste_recycled)
    ) %>%
    mutate(avg_rate = round(avg_rate, 1)) %>%
    arrange(desc(avg_rate))
  
  return(country_stats)
}

#' Get top N and bottom N performing countries
#'
#' @param country_stats Dataframe from calculate_country_stats()
#' @param n Number of top/bottom countries to return (default 5)
#' @return Dataframe with selected top and bottom performers
#'
get_top_bottom_performers <- function(country_stats, n = 5) {
  top_countries <- country_stats %>%
    slice_max(avg_rate, n = n) %>%
    pull(country)
  
  bottom_countries <- country_stats %>%
    slice_min(avg_rate, n = n) %>%
    pull(country)
  
  return(c(top_countries, bottom_countries))
}

# ============================================================================
# VISUALIZATION FUNCTIONS
# ============================================================================

#' Create time series plot of EU average e-waste recycling
#'
#' @param yearly_avg Dataframe from calculate_yearly_average()
#' @return ggplot object
#'
plot_time_series <- function(yearly_avg) {
  ggplot(yearly_avg, aes(x = year, y = avg_ewaste)) +
    geom_line(color = COLOR_PRIMARY, linewidth = 1.3) +
    geom_point(color = COLOR_PRIMARY, size = 3) +
    labs(
      title = "EU Average E-Waste Recycling Rate Over Time",
      subtitle = "Yearly trend across all countries",
      x = "Year",
      y = "Recycling Rate (%)",
      caption = "Source: EU E-Waste Data"
    ) +
    scale_y_continuous(
      limits = c(0, 50),
      labels = percent_format(scale = 1)
    ) +
    scale_x_continuous(
      breaks = pretty_breaks(),
      labels = function(x) format(x, nsmall = 0)
    ) +
    THEME_MINIMAL_CUSTOM()
}

#' Create bar chart of top 10 countries (latest year)
#'
#' @param ewaste_clean Cleaned dataframe
#' @return ggplot object
#'
plot_top_countries <- function(ewaste_clean) {
  latest_year <- max(ewaste_clean$year)
  
  latest_data <- ewaste_clean %>%
    filter(year == latest_year) %>%
    arrange(desc(e_waste_recycled)) %>%
    slice_head(n = 10)
  
  ggplot(latest_data, aes(x = reorder(country, e_waste_recycled), y = e_waste_recycled)) +
    geom_col(fill = COLOR_PRIMARY, width = 0.6) +
    coord_flip() +
    labs(
      title = paste("Top 10 E-Waste Recycling Rate by Country -", latest_year),
      x = "Country",
      y = "Recycling Rate (%)"
    ) +
    scale_y_continuous(labels = percent_format(scale = 1), expand = c(0, 0)) +
    THEME_MINIMAL_CUSTOM()
}

#' Create heatmap of all countries over time
#'
#' @param ewaste_clean Cleaned dataframe
#' @return ggplot object
#'
plot_heatmap <- function(ewaste_clean) {
  ggplot(ewaste_clean, aes(x = year, y = country, fill = e_waste_recycled)) +
    geom_tile() +
    scale_fill_gradient(
      low = COLOR_HEATMAP_LOW,
      high = COLOR_HEATMAP_HIGH,
      name = "Recycling %",
      labels = percent_format(scale = 1)
    ) +
    labs(
      title = "E-Waste Recycling Rates Heatmap",
      x = "Year",
      y = "Country"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

#' Create comparison plot: top vs bottom performers
#'
#' @param ewaste_clean Cleaned dataframe
#' @param country_stats Dataframe from calculate_country_stats()
#' @param n Number of top/bottom countries (default 5)
#' @return ggplot object
#'
plot_top_vs_bottom <- function(ewaste_clean, country_stats, n = 5) {
  selected_countries_list <- get_top_bottom_performers(country_stats, n)
  
  selected_countries <- ewaste_clean %>%
    filter(country %in% selected_countries_list)
  
  ggplot(selected_countries, aes(x = year, y = e_waste_recycled, color = country, group = country)) +
    geom_line(linewidth = 1) +
    geom_point(size = 3) +
    labs(
      title = "E-Waste Recycling Rate Trends: Top vs Bottom Performers",
      x = "Year",
      y = "Recycling Rate (%)"
    ) +
    scale_y_continuous(labels = percent_format(scale = 1)) +
    scale_x_continuous(
      breaks = pretty_breaks(),
      labels = function(x) format(x, nsmall = 0)
    ) +
    scale_color_brewer(palette = "Paired") +
    THEME_MINIMAL_CUSTOM()
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================

#' Save ggplot to file with standard settings
#'
#' @param plot ggplot object
#' @param filename Output filename (without path)
#' @return NULL (invisibly)
#'
save_plot <- function(plot, filename) {
  filepath <- file.path(PATH_OUTPUT_PLOTS, filename)
  ggsave(
    filepath,
    plot = plot,
    width = PLOT_WIDTH,
    height = PLOT_HEIGHT,
    dpi = PLOT_DPI,
    bg = "white"
  )
  cat("✓ Saved:", filepath, "\n")
}
