# load packages
library(tidyverse) #For data manipulation and ggplot2
library(skimr) 
library(janitor)
library(scales) #For better axis formatting
library(knitr) #For nice table formatting

# Import dataset

# Import data from .csv file from our local computer.
ewaste_df <- read_csv("ewaste_europe.csv")

# Preview first few rows of dataset.
head(ewaste_df)

# Check for missing values
colSums(is.na(ewaste_df))

# Examine the structure of the dataset
glimpse(ewaste_df)

{r examine data clounms}
# This is to ensure that all the critical columns needed for the analysis are intact
colnames(ewaste_df)

# Examine the detail summary of the dataset
skim_without_charts(ewaste_df)

# Overall EU average by year
yearly_avg <- ewaste_clean %>%
  group_by(year) %>%
  summarise(avg_ewaste = mean(`e_waste_recycled`, na.rm = TRUE)
  ) %>%
  mutate(avg_ewaste = round(avg_ewaste, 1))

# Country performance analysis
country_stats <- ewaste_clean %>%
  group_by(country) %>%
  summarise(
    avg_rate = mean(`e_waste_recycled`),
    min_rate = min(`e_waste_recycled`),
    max_rate = max(`e_waste_recycled`),
    improvement = last(`e_waste_recycled`) - first(`e_waste_recycled`)
  ) %>%
  mutate(avg_rate = round(avg_rate, 1)) %>%
  arrange(desc(avg_rate))

# Time series of EU average 
ggplot(yearly_avg, aes(x = year, y = avg_ewaste )) +
  geom_line(color = "#006837", size = 1.3) +
  geom_point(color = "#006837", size = 3) +
  labs(title = "EU Average E-Waste Recycling Rate Over Time",
       subtitle = "Yearly trend across all countries",
       x = "Year",
       y = "Recycling Rate (%)",
       caption = "Source: EU E-Waste Data") +
  scale_y_continuous(
    limits = c(0, 50), 
    labels = percent_format(scale = 1)
    ) +
  scale_x_continuous(
    breaks = pretty_breaks(), 
    labels = function(x) format(x, nsmall = 0)
    )+ 
  theme_minimal() + 
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5), 
    plot.subtitle = element_text(hjust = 0.4))

# Country comparison(latest year)

# Get latest year data
latest_year <- max(ewaste_clean$year)

latest_data <- ewaste_clean %>%
  filter(year == latest_year) %>%
  arrange(desc(`e_waste_recycled`))

# Get top 10 countries by recycling rate
latest_data <- ewaste_clean %>% 
  filter(year == latest_year) %>% 
  arrange(desc(e_waste_recycled)) %>% 
  slice_head(n = 10)

ggplot(latest_data, aes(x = reorder(country, `e_waste_recycled`), 
                        y = `e_waste_recycled`)
       ) + 
  geom_col(fill = "#006837", width = 0.6) +
  coord_flip() +
  labs(title = paste("Top 10 E-Waste Recycling Rate by Country -", latest_year),
       x = "Country",
       y = "Recycling Rate (%)"
       ) +
  scale_y_continuous(labels = percent_format(scale = 1), expand = c(0, 0)
                     ) +
  theme_minimal() +
  theme(
    panel.grid.major.y = element_blank(),
    plot.title = element_text(face = "bold", hjust = 0.5))

# Heatmap of all countries overtime 
ggplot(ewaste_clean, aes(x = year, y = country, fill = `e_waste_recycled`)
       ) + 
  geom_tile() + 
  scale_fill_gradient(low = "#ffffcc", high = "#006837", 
                      name = "Recycling %", 
                      labels = percent_format(scale = 1)
                      ) + 
  labs(title = "E-Waste Recycling Rates Heatmap", 
       x = "Year", 
       y = "Country") + 
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1)
        )

# Identify top and bottom performers
top_countries <- country_stats %>%
  slice_max(avg_rate, n = 5) %>%
  pull(country)

bottom_countries <- country_stats %>%
  slice_min(avg_rate, n = 5) %>%
  pull(country)

selected_countries <- ewaste_clean %>%
  filter(country %in% c(top_countries, bottom_countries))

ggplot(selected_countries, aes(x = year, y = `e_waste_recycled`, 
                              color = country, group = country)
       ) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  labs(title = "E-Waste Recycling Rate Trends: Top vs Bottom Performers",
       x = "Year",
       y = "Recycling Rate (%)") +
  scale_y_continuous(labels = percent_format(scale = 1)
                     ) +
   scale_x_continuous(
    breaks = pretty_breaks(), 
    labels = function(x) format(x, nsmall = 0)) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  scale_color_brewer(palette = "Paired")

