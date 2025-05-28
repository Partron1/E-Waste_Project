## E-WASTE TREND ANALYSIS
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
