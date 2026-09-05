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
  excluded_columns <- c(
    "European Union - 27 countries",
    "European Union - 28 countries",
    "Iceland",
    "Liechtenstein",
    "Norway"
  )

  ewaste_filter <- ewaste_df %>%
    select(-any_of(excluded_columns))
  
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

#' Calculate yearly EU average e-waste recycling rate with trend analysis
#'
#' @param ewaste_clean Cleaned dataframe
#' @return Dataframe with year, avg_ewaste, and trend metrics
#'
calculate_yearly_average <- function(ewaste_clean) {
  yearly_avg <- ewaste_clean %>%
    group_by(year) %>%
    summarise(avg_ewaste = mean(e_waste_recycled, na.rm = TRUE)) %>%
    mutate(
      avg_ewaste = round(avg_ewaste, 1),
      year_lag = lag(avg_ewaste),
      yoy_change = avg_ewaste - year_lag,
      direction = ifelse(yoy_change >= 0, "Improvement", "Decline")
    )
  
  return(yearly_avg)
}

#' Calculate per-country performance statistics with trajectory
#'
#' @param ewaste_clean Cleaned dataframe
#' @return Dataframe with country stats (avg, min, max, improvement, trajectory)
#'
calculate_country_stats <- function(ewaste_clean) {
  country_stats <- ewaste_clean %>%
    arrange(country, year) %>%
    group_by(country) %>%
    summarise(
      avg_rate = mean(e_waste_recycled),
      min_rate = min(e_waste_recycled),
      max_rate = max(e_waste_recycled),
      improvement = last(e_waste_recycled) - first(e_waste_recycled),
      trajectory = ifelse(improvement > 5, "Strong Growth", 
                         ifelse(improvement > 0, "Modest Growth", "Declining"))
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
# VISUALIZATION FUNCTIONS (ENHANCED)
# ============================================================================

#' Create enhanced time series plot with story elements
#'
#' @param yearly_avg Dataframe from calculate_yearly_average()
#' @return ggplot object
#'
plot_time_series <- function(yearly_avg) {
  ggplot(yearly_avg, aes(x = year, y = avg_ewaste)) +
    geom_ribbon(aes(ymin = 0, ymax = avg_ewaste, fill = "Recycling Progress"), 
                alpha = 0.25, color = NA) +
    geom_line(color = "#1b5e20", linewidth = 1.5, linetype = "solid") +
    geom_point(aes(color = direction), size = 4, stroke = 1.5, shape = 21, fill = "white") +
    geom_text(aes(label = paste0(avg_ewaste, "%")), 
              vjust = -1.2, hjust = 0.5, size = 3.2, fontface = "bold") +
    geom_hline(yintercept = mean(yearly_avg$avg_ewaste, na.rm = TRUE), 
               linetype = "dashed", color = "#999999", linewidth = 0.8, alpha = 0.6) +
    annotate("text", x = min(yearly_avg$year), y = mean(yearly_avg$avg_ewaste, na.rm = TRUE) + 1.5,
             label = "Mean Recycling Rate", size = 3, color = "#666666", hjust = 0, fontface = "italic") +
    labs(
      title = "EU E-Waste Recycling Progress: A Decade of Growth",
      subtitle = "Annual average recycling rates across EU member states show consistent upward trajectory",
      x = "Year",
      y = "Recycling Rate (%)",
      caption = "Source: EU E-Waste Data | Color indicates year-over-year performance direction",
      fill = "",
      color = "Year-on-Year"
    ) +
    scale_y_continuous(
      limits = c(0, 55),
      breaks = seq(0, 50, by = 10),
      labels = percent_format(scale = 1)
    ) +
    scale_x_continuous(breaks = pretty_breaks(n = 8)) +
    scale_fill_manual(values = "#1b5e20") +
    scale_color_manual(values = c("Improvement" = "#2e7d32", "Decline" = "#c62828")) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0.5, margin = margin(b = 5)),
      plot.subtitle = element_text(size = 12, hjust = 0.5, color = "#555555", margin = margin(b = 15)),
      panel.grid.major.x = element_line(color = "#e0e0e0", linewidth = 0.3),
      panel.grid.major.y = element_line(color = "#f5f5f5", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      plot.caption = element_text(size = 10, color = "#888888", hjust = 0),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10),
      legend.position = "top",
      legend.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA)
    )
}

#' Create enhanced bar chart of top 10 countries with diverging colors
#'
#' @param ewaste_clean Cleaned dataframe
#' @return ggplot object
#'
plot_top_countries <- function(ewaste_clean) {
  latest_year <- max(ewaste_clean$year)
  latest_data <- ewaste_clean %>% 
    filter(year == latest_year) %>% 
    arrange(desc(e_waste_recycled)) %>% 
    slice_head(n = 10) %>%
    mutate(
      performance = ifelse(e_waste_recycled >= median(e_waste_recycled), 
                           "Above Median", "Below Median"),
      country = fct_reorder(country, e_waste_recycled)
    )

  ggplot(latest_data, aes(x = country, y = e_waste_recycled, fill = performance)) +
    geom_col(width = 0.7, color = "white", linewidth = 1) +
    geom_text(aes(label = paste0(round(e_waste_recycled, 1), "%")), 
              vjust = -0.5, size = 3.5, fontface = "bold", color = "#333333") +
    coord_flip() +
    labs(
      title = paste("Top 10 Performers in E-Waste Recycling", latest_year),
      subtitle = "Latest year comparison showing leaders in sustainability efforts",
      x = "",
      y = "Recycling Rate (%)",
      fill = "Performance Level",
      caption = "Source: EU E-Waste Data"
    ) +
    scale_y_continuous(
      limits = c(0, max(latest_data$e_waste_recycled) * 1.15),
      labels = percent_format(scale = 1),
      expand = c(0, 0)
    ) +
    scale_fill_manual(
      values = c("Above Median" = "#1b5e20", "Below Median" = "#81c784"),
      guide = guide_legend(reverse = TRUE)
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0, margin = margin(b = 5)),
      plot.subtitle = element_text(size = 11, hjust = 0, color = "#666666", margin = margin(b = 12)),
      panel.grid.major.x = element_line(color = "#f0f0f0", linewidth = 0.3),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      axis.title.x = element_text(size = 11, face = "bold"),
      axis.title.y = element_blank(),
      axis.text.y = element_text(size = 10, color = "#333333"),
      axis.text.x = element_text(size = 10),
      legend.position = "top",
      legend.title = element_text(size = 10, face = "bold"),
      legend.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      plot.caption = element_text(size = 9, color = "#888888", hjust = 0)
    )
}

#' Create enhanced heatmap with annotations and sorted countries
#'
#' @param ewaste_clean Cleaned dataframe
#' @return ggplot object
#'
plot_heatmap <- function(ewaste_clean) {
  # Sort countries by average performance for better readability
  country_order <- ewaste_clean %>%
    group_by(country) %>%
    summarise(avg_rate = mean(e_waste_recycled)) %>%
    arrange(desc(avg_rate)) %>%
    pull(country)

  ewaste_sorted <- ewaste_clean %>%
    mutate(country = factor(country, levels = country_order))

  ggplot(ewaste_sorted, aes(x = year, y = country, fill = e_waste_recycled)) +
    geom_tile(color = "white", linewidth = 0.5) +
    geom_text(aes(label = ifelse(e_waste_recycled > 40 | e_waste_recycled < 15, 
                                 round(e_waste_recycled, 0), "")),
              color = "white", size = 2.5, fontface = "bold") +
    scale_fill_gradient(
      low = "#fff9c4",     # Light yellow for low values
      high = "#1b5e20",    # Dark green for high values
      name = "Recycling Rate (%)",
      labels = percent_format(scale = 1),
      breaks = seq(0, 50, by = 10)
    ) +
    labs(
      title = "E-Waste Recycling Heatmap: Country Performance Over Time",
      subtitle = "Darker shades indicate higher recycling rates; lighter shades indicate lower performance",
      x = "Year",
      y = "Country",
      caption = "Source: EU E-Waste Data | Values shown for extreme performers (>40% or <15%)"
    ) +
    scale_x_continuous(breaks = pretty_breaks()) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0, margin = margin(b = 5)),
      plot.subtitle = element_text(size = 11, hjust = 0, color = "#666666", margin = margin(b = 12)),
      axis.text.x = element_text(angle = 45, hjust = 1, size = 9),
      axis.text.y = element_text(size = 8),
      axis.title = element_text(size = 11, face = "bold"),
      legend.position = "right",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),
      panel.grid = element_blank(),
      plot.background = element_rect(fill = "white", color = NA),
      plot.caption = element_text(size = 9, color = "#888888", hjust = 0)
    )
}

#' Create performance contrast plot: top vs bottom performers with facets
#'
#' @param ewaste_clean Cleaned dataframe
#' @param country_stats Dataframe from calculate_country_stats()
#' @param n Number of top/bottom countries (default 5)
#' @return ggplot object
#'
plot_top_vs_bottom <- function(ewaste_clean, country_stats, n = 5) {
  top_countries <- country_stats %>%
    slice_max(avg_rate, n = n) %>%
    pull(country)

  bottom_countries <- country_stats %>%
    slice_min(avg_rate, n = n) %>%
    pull(country)

  selected_countries <- ewaste_clean %>%
    filter(country %in% c(top_countries, bottom_countries)) %>%
    mutate(
      performance_group = ifelse(country %in% top_countries, "Top Performers", "Bottom Performers"),
      country_label = paste0(country, "\n", 
                            ifelse(country %in% top_countries, "↑", "↓"))
    )

  ggplot(selected_countries, 
         aes(x = year, y = e_waste_recycled, 
             color = performance_group, 
             fill = performance_group,
             group = country,
             linetype = performance_group)) +
    geom_line(linewidth = 1.1, alpha = 0.9) +
    geom_point(size = 3.5, stroke = 1.2, shape = 21, color = "white") +
    facet_wrap(~performance_group, nrow = 1, scales = "free_y") +
    labs(
      title = "Divergent Trajectories: Top vs Bottom E-Waste Recycling Performers",
      subtitle = "Clear separation between leading and lagging countries highlights performance gap",
      x = "Year",
      y = "Recycling Rate (%)",
      color = "Performance Group",
      fill = "Performance Group",
      linetype = "Performance Group",
      caption = "Source: EU E-Waste Data | Faceted view emphasizes distinct performance patterns"
    ) +
    scale_y_continuous(labels = percent_format(scale = 1)) +
    scale_x_continuous(breaks = pretty_breaks()) +
    scale_color_manual(
      values = c("Top Performers" = "#1b5e20", "Bottom Performers" = "#f57c00"),
      guide = "none"
    ) +
    scale_fill_manual(
      values = c("Top Performers" = "#1b5e20", "Bottom Performers" = "#f57c00"),
      guide = "none"
    ) +
    scale_linetype_manual(
      values = c("Top Performers" = "solid", "Bottom Performers" = "dashed"),
      guide = "none"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0, margin = margin(b = 5)),
      plot.subtitle = element_text(size = 11, hjust = 0, color = "#666666", margin = margin(b = 12)),
      panel.grid.major = element_line(color = "#f5f5f5", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 9),
      strip.text = element_text(size = 11, face = "bold", color = "white"),
      strip.background = element_rect(fill = "#1b5e20", color = NA),
      legend.position = "top",
      plot.background = element_rect(fill = "white", color = NA),
      plot.caption = element_text(size = 9, color = "#888888", hjust = 0)
    )
}

#' Create improvement analysis plot showing country progress
#'
#' @param country_stats Dataframe from calculate_country_stats()
#' @return ggplot object
#'
plot_improvement <- function(country_stats) {
  country_improvement <- country_stats %>%
    arrange(improvement) %>%
    mutate(
      country = fct_reorder(country, improvement),
      improvement_category = case_when(
        improvement > 10 ~ "Exceptional Growth (>10%)",
        improvement > 5 ~ "Strong Growth (5-10%)",
        improvement > 0 ~ "Modest Growth (0-5%)",
        TRUE ~ "Decline or Stagnation (≤0%)"
      ),
      color_group = ifelse(improvement >= 0, "Improvement", "Decline")
    )

  ggplot(country_improvement, 
         aes(x = country, y = improvement, fill = improvement_category)) +
    geom_col(width = 0.75, color = "white", linewidth = 0.8) +
    geom_hline(yintercept = 0, color = "#333333", linewidth = 0.8) +
    geom_text(aes(label = paste0("+", round(improvement, 1), "%"), 
                  vjust = ifelse(improvement > 0, -0.5, 1.5)),
              size = 3, fontface = "bold", color = "#333333") +
    coord_flip() +
    labs(
      title = "Country Progress: Improvement Over the Decade",
      subtitle = "Measuring change from first to latest recorded year - showing who's committed to sustainability",
      x = "",
      y = "Percentage Point Improvement",
      fill = "Growth Category",
      caption = "Source: EU E-Waste Data | Positive values = improvement; Negative = decline"
    ) +
    scale_y_continuous(labels = function(x) paste0(x, "%")) +
    scale_fill_manual(
      values = c(
        "Exceptional Growth (>10%)" = "#1b5e20",
        "Strong Growth (5-10%)" = "#43a047",
        "Modest Growth (0-5%)" = "#81c784",
        "Decline or Stagnation (≤0%)" = "#e57373"
      ),
      guide = guide_legend(reverse = TRUE)
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0, margin = margin(b = 5)),
      plot.subtitle = element_text(size = 11, hjust = 0, color = "#666666", margin = margin(b = 12)),
      panel.grid.major.x = element_line(color = "#f0f0f0", linewidth = 0.3),
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      axis.title.x = element_text(size = 11, face = "bold"),
      axis.title.y = element_blank(),
      axis.text.y = element_text(size = 9, color = "#333333"),
      axis.text.x = element_text(size = 10),
      legend.position = "top",
      legend.title = element_text(size = 10, face = "bold"),
      legend.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      plot.caption = element_text(size = 9, color = "#888888", hjust = 0)
    )
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
