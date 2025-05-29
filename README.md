## E-WASTE TREND ANALYSIS: A DECADE OF DIGITAL DISCARD
## Table of Content
- [Objective](Objective)
- [Business Context](Business-Context)
- [Key Stakeholders](Key-Stakeholders)
- [Business Questions](Business-Questions)
- [Data Description](Data-Description)
- [Exploratory Data Analysis](Exploratory-Data-Analysis(EDA))
- [Data Transformation](Data-Transformation)
- [Visualization](Visualization)

### OBJECTIVE:

To analyze historical e-waste recycling data across 28 EU member countries from 2008 to 2018

### BUSINESS CONTEXT:

Electrical and electronic equipment (EEE) has become essential to everyday life. Its availability and widespread use have enabled much of the global population to benefit from higher living standards.

- Global E-Waste Generation: In 2019, 53.6 million metric tons (Mt) of e-waste were generated worldwide. This marks an increase of 9.2 Mt since 2014.

- Recycling Shortfalls: Only 17.4% of e-waste was officially documented as properly collected and recycled in 2019. Although recycling increased by 1.8 Mt, it did not keep pace with the overall growth in e-waste.

- Regional Insights – Europe: Highest per capita e-waste generation: 16.2 kg per person.

- Leading in recycling rates: 42.5% of e-waste was properly collected and recycled, the highest among all continents

Source : (Global E-waste Monitor 20220){https://www.itu.int/pub/D-GEN-E_WASTE.01-2020}

![picture](https://github.com/user-attachments/assets/474d25a6-4341-476f-ab9b-8243e62f9906)

### KEY STAKEHOLDERS:

#### European Environmental Agency (EEA):

Assessing policy effectiveness and setting new e-waste reduction targets.

#### Recycling and waste management companies:

Identifying high-growth markets for e-waste processing.

#### Tech and Electronic Manufacturers:  
Understanding consumer disposal trends for product life-cycle planning.

#### Sustainability NGOs and Research Institutions:
Advocating for better e-waste policies and public awareness.

### BUSINESS QUESSIONS:

1. How has e-waste recycling evolved in EU countries over the past decade?
2. Which countries have the highest/lowest e-waste recycling rate, and what factors contribute to these trends?
3. Can we predict future e-waste volumes based on historical trends?  

### DATA DESCRIPTION

#### Data sources:

The EU e-waste recycling public dataset was downloaded from Kaggle.

#### Data type:

Structured data organized in a .csv file

#### Credibility:

The data seems reliable. However, we should note potential sampling or data-entry errors.

#### Plan:

- Clean dataset with R

- Use R Studio to process, analyze, and visualize the data.

- Use R Markdown to save and present results.

- Shiny will be used to build a compelling dashboard.

### EXPLORATORY DATA ANALYSIS (EDA)

```r load packages
library(tidyverse) #For data manipulation and ggplot2
library(skimr) 
library(janitor)
library(scales) #For better axis formatting
library(knitr) #For nice table formatting
```
```
# Import data from .csv file from our local computer.
ewaste_df <- read_csv("ewaste_europe.csv")
```
```
# Preview first few rows of dataset.
head(ewaste_df)
```
```
# Check for missing values
colSums(is.na(ewaste_df))
```
```
# Examine the structure of the dataset
glimpse(ewaste_df)
```
```
# Examine the column names
colnames(ewaste_df)
```
```
# Examine the detail summary of the dataset
skim_without_charts(ewaste_df)
```
```
# Drop some critical columns that are irrelevant to the analysis.
ewaste_filter <- ewaste_df[, -c(12, 13, 19, 21, 27)]
```
### DATA TRANSFORMATION

#### Cleaning steps:

1. Loaded the dataset into R Studio
2. Examine dataset
3. Drop column
4. Convert the dataset from wide to long to make it more organized and readable.
5. Remove duplicates
6. Remove NA values in critical columns
7. Rename some columns

Note: The steps ensure that our data is clean and ready for analysis

### Tools Used:

- 10% Excel

- 90% R programming language

```
# Convert dataset from wide to long data type to ensure data is more organized and readable
ewaste_clean <- ewaste_filter %>% 
  pivot_longer(
    cols = !period,
    names_to = "country",
    values_to = "ewaste_recycled"
  ) %>%
  # Drop NAs and rename column
  drop_na() %>%
  # Format data type
  rename(year = period, e_waste_recycled = ewaste_recycled) %>%
  mutate(
    country = as.factor(country),
    year = as.integer(year),
    e_waste_recycled = as.numeric(e_waste_recycled)
  )
```
```
# summary of our cleaned dataset
summary(ewaste_clean)
```
```
# Examine the table of the cleaned data
table(ewaste_clean$country)
```
```
# Examine the structure of the dataset
glimpse(ewaste_clean)
```
#### Possible questions:
1. Percentage of e-waste recycled over time?
2. Which country recycled the most/least e-waste in a given year?
3. Are there upward or downward trends in e-waste recycling across countries?
4. Which countries are experiencing the fastest growth in e-waste recycling?
5. How do countries compare in terms of e-waste recycling?
6. Which countries might benefit from improved e-waste management policies?

```
# Overall EU average by year
yearly_avg <- ewaste_clean %>%
  group_by(year) %>%
  summarise(avg_ewaste = mean(`e_waste_recycled`, na.rm = TRUE)
  ) %>%
  mutate(avg_ewaste = round(avg_ewaste, 1))
```
```
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
```
### Visualizations:

#### Time Series of EU Average
```
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
```
![000010](https://github.com/user-attachments/assets/c71d7a50-4827-43e4-9003-10646b9db311)

### Country Comparison(latest year)
```
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
```
![000013](https://github.com/user-attachments/assets/a52e5039-3491-442e-a321-386c0ba750e3)

### Heatmap of All Countiries Overtime
```
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
```
![000012](https://github.com/user-attachments/assets/920bba00-94ea-4336-ac79-9683a7e56e17)

### Top & Bottom Performers Comparison
```
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
```
![000014](https://github.com/user-attachments/assets/f541e9ac-7739-4258-b773-0ed0684cfe07)

### Key Findings:

#### Overall Recycling Performance: EU vs Global Trends

From 2008 to 2018, the average e-waste recycling rate across 28 EU countries was 35.6%. This is over double the global recycling rate in 2019, which stood at just 17.4%.A positive indication that EU policy mechanisms, such as the WEEE Directive, have been relatively effective compared to global efforts. The EU's average(35.6%) outperformed the global rate (17.4%), but the 2019 figure (42.5% for Europe) indicates that progress continued post-2018, building on the trends identified.

### Plot Findings

### Trends and Policy Impact

The line plot visualization shows the EU's e-waste recycling rate initially rose in 2008 but declined in 2009, possibly due to the financial crisis reducing recycling investments. From 2010 onward, the rate increased steadily, reflecting the success of EU policies like the WEEE Directive and improved recycling infrastructure. 
However, the 2009 dip underscores the need for resilient systems that withstand economic fluctuations. 
Moving forward, maintaining this upward trend requires stronger enforcement, innovation in recycling technologies, and enhanced public engagement.

### Disparities in EU Country Performance

- In the bar chart, Croatia leads with a significantly higher rate above 80% than the 10th-ranked country(Germany).
  Croatia, Denmark, the UK, and Bulgaria exceed the EU target(65%), but Germany falls short(<50%).
  The range is wide(>80% and <50%), suggesting uneven e-waste management policies across the EU.

- The heatmap displays e-waste recycling rates(%) for 28 EU countries(y-axis) over the period 2008-2018(x-axis), with color intensity reflecting performance(deep green = 100%, fading to light = 25%).
Countries like Croatia and Bulgaria gave a steady improvement, with recycling rates rising from light to dark green between 2012-2018 due to robust policies.
Sweden's rate surged from 2008 to 2014 but dropped afterward, possibly due to temporary measures or data reporting shifts.
The majority of the countries lagged, with rates near 25% in most years, suggesting persistent challenges.
Economic growth, population density, or consumer behavior could influence trends but aren't visible here.

- For the Top vs Bottom performance, Bulgaria performed better, whilst Malta performed poorly.

### Conclusions

The EU analysis foreshadowed the 2019 global trends: while Europe leads, its inconsistencies (economic sensitivity, uneven adoption) reflect broader systemic failures. 
By pairing 2008–2018 insights (e.g., policy-driven growth, top/bottom performers) with 2019’s 42.5% recycling rate and 16.2 kg/capita waste, we create a data-driven call to action: replicate Croatia’s success globally and address economic/policy barriers to close the e-waste gap.
