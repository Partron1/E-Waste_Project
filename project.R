# load packages
library(tidyverse) #For data manipulation and ggplot2
library(skimr) 
library(janitor)
library(scales) #For better axis formatting
library(knitr) #For nice table formatting
library(ggtext) #For rich text formatting in plots
library(patchwork) #For combining multiple plots

# Load configuration and functions
source("config.R")
source("functions.R")

# Import dataset

# Import data from .csv file from our local computer.
ewaste_df <- read_csv(FILE_EWASTE_RAW)

# Preview first few rows of dataset.
head(ewaste_df)

# Check for missing values
colSums(is.na(ewaste_df))

# Examine the structure of the dataset
glimpse(ewaste_df)

# Examine column names
# This is to ensure that all the critical columns needed for the analysis are intact
colnames(ewaste_df)

# Examine the detail summary of the dataset
skim_without_charts(ewaste_df)

# Clean the data
ewaste_clean <- clean_ewaste_data(ewaste_df)

# ============================================================================
# ANALYSIS PREPARATION
# ============================================================================

# Overall EU average by year
yearly_avg <- ewaste_clean %>%
  group_by(year) %>%
  summarise(avg_ewaste = mean(e_waste_recycled, na.rm = TRUE)) %>%
  mutate(
    avg_ewaste = round(avg_ewaste, 1),
    year_lag = lag(avg_ewaste),
    yoy_change = avg_ewaste - year_lag,
    direction = ifelse(yoy_change >= 0, "Improvement", "Decline")
  )

# Country performance analysis
country_stats <- ewaste_clean %>%
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

# ============================================================================
# VISUALIZATION 1: TIME SERIES WITH STORY ELEMENTS
# ============================================================================
# This visualization emphasizes the overall trend and highlights critical insights

plot_eu_trend <- ggplot(yearly_avg, aes(x = year, y = avg_ewaste)) +
  # Add gradient background to show progression
  geom_ribbon(aes(ymin = 0, ymax = avg_ewaste, fill = "Recycling Progress"), 
              alpha = 0.25, color = NA) +
  geom_line(color = "#1b5e20", linewidth = 1.5, linetype = "solid") +
  geom_point(aes(color = direction), size = 4, stroke = 1.5, shape = 21, fill = "white") +
  # Annotate key insights
  geom_text(aes(label = paste0(avg_ewaste, "%")), 
            vjust = -1.2, hjust = 0.5, size = 3.2, fontface = "bold") +
  # Add reference lines for context
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

print(plot_eu_trend)

# ============================================================================
# VISUALIZATION 2: COUNTRY COMPARISON WITH DIVERGING COLORS
# ============================================================================
# Clearly separate high and low performers using diverging color scheme

latest_year <- max(ewaste_clean$year)
latest_data <- ewaste_clean %>% 
  filter(year == latest_year) %>% 
  arrange(desc(e_waste_recycled)) %>% 
  slice_head(n = 10) %>%
  mutate(
    performance = ifelse(e_waste_recycled >= median(latest_data$e_waste_recycled), 
                         "Above Median", "Below Median"),
    country = fct_reorder(country, e_waste_recycled)
  )

plot_top_countries <- ggplot(latest_data, aes(x = country, y = e_waste_recycled, fill = performance)) +
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

print(plot_top_countries)

# ============================================================================
# VISUALIZATION 3: ENHANCED HEATMAP WITH ANNOTATIONS
# ============================================================================
# Color intensity makes variation patterns immediately visible

# Sort countries by average performance for better readability
country_order <- ewaste_clean %>%
  group_by(country) %>%
  summarise(avg_rate = mean(e_waste_recycled)) %>%
  arrange(desc(avg_rate)) %>%
  pull(country)

ewaste_sorted <- ewaste_clean %>%
  mutate(country = factor(country, levels = country_order))

plot_heatmap_enhanced <- ggplot(ewaste_sorted, aes(x = year, y = country, fill = e_waste_recycled)) +
  geom_tile(color = "white", linewidth = 0.5) +
  # Add value labels for key cells
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

print(plot_heatmap_enhanced)

# ============================================================================
# VISUALIZATION 4: TOP vs BOTTOM WITH CONTRASTING AESTHETICS
# ============================================================================
# Clear visual distinction between high and low performers tells the story

top_countries <- country_stats %>%
  slice_max(avg_rate, n = 5) %>%
  pull(country)

bottom_countries <- country_stats %>%
  slice_min(avg_rate, n = 5) %>%
  pull(country)

selected_countries <- ewaste_clean %>%
  filter(country %in% c(top_countries, bottom_countries)) %>%
  mutate(
    performance_group = ifelse(country %in% top_countries, "Top Performers", "Bottom Performers"),
    country_label = paste0(country, "\n", 
                          ifelse(country %in% top_countries, "↑", "↓"))
  )

plot_performance_contrast <- ggplot(selected_countries, 
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

print(plot_performance_contrast)

# ============================================================================
# VISUALIZATION 5: IMPROVEMENT ANALYSIS - SHOWING WHO'S PROGRESSING
# ============================================================================
# Highlights which countries are making real progress vs stagnating

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

plot_improvement <- ggplot(country_improvement, 
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

print(plot_improvement)

# ============================================================================
# OPTIONAL: SAVE ALL PLOTS
# ============================================================================
# Uncomment the lines below to save plots to the output folder

# save_plot(plot_eu_trend, "01_EU_Trend_Analysis.png")
# save_plot(plot_top_countries, "02_Top_Countries.png")
# save_plot(plot_heatmap_enhanced, "03_Heatmap_Analysis.png")
# save_plot(plot_performance_contrast, "04_Performance_Contrast.png")
# save_plot(plot_improvement, "05_Improvement_Analysis.png")

# ============================================================================
# SUMMARY STATISTICS FOR REPORTING
# ============================================================================

# Overall progress
overall_start <- yearly_avg %>% slice(1) %>% pull(avg_ewaste)
overall_end <- yearly_avg %>% slice(n()) %>% pull(avg_ewaste)
overall_change <- overall_end - overall_start

cat("\n=== E-WASTE RECYCLING ANALYSIS SUMMARY ===\n")
cat("Overall EU Progress:", overall_change %>% round(2), "percentage points\n")
cat("Starting Average:", overall_start, "%\n")
cat("Ending Average:", overall_end, "%\n")
cat("\nCountries with Best Performance:\n")
print(head(country_stats, 5))
