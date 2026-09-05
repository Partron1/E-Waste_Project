### E-Waste Trend Analysis: A Decade Of Digital Discard
**Table of Content**

- [Objective](#Objective)
- [Business Context](#business-context)
- [Key Stakeholders](#key-stakeholders)
- [Business Questions](#business-questions)
- [Key Findings](#key-findings)
- [Conclusions](#conclusions)

**Objective:**
To analyze historical e-waste recycling data across 28 EU member countries from 2008 to 2018

**Business Context:**

Electrical and electronic equipment (EEE) has become essential to everyday life. Its availability and widespread use have enabled much of the global population to benefit from higher living standards.

- *Global E-Waste Generation: In 2019, **53.6 million metric tons (Mt)** of e-waste were generated worldwide. This marks an increase of **9.2 Mt since 2014**.*

- *Recycling Shortfalls: Only **17.4%** of e-waste was officially documented as properly collected and recycled in 2019. Although recycling increased by **1.8 Mt**, it did not keep pace with the overall growth in e-waste.*

- *Regional Insights – **Europe**: Highest per capita e-waste generation(**16.2 kg** per person).*

- *Leading in recycling rates: **42.5%** of e-waste was properly collected and recycled, the highest among all continents.*

[Read More...](https://www.itu.int/pub/D-GEN-E_WASTE.01-2020)

**Key Stakeholders:**

- **European Environmental Agency (EEA):** *Assessing policy effectiveness and setting new e-waste reduction targets.*

- **Recycling and waste management companies:** *Identifying high-growth markets for e-waste processing.*

- **Tech and Electronic Manufacturers:** *Understanding consumer disposal trends for product life-cycle planning.*

- **Sustainability NGOs and Research Institutions:** *Advocating for better e-waste policies and public awareness.*

**Business Question:**

1. How has e-waste recycling evolved in EU countries over the past decade?
2. Which countries have the highest/lowest e-waste recycling rate, and what factors contribute to these trends?
3. Can we predict future e-waste volumes based on historical trends?  

**Data Description**

- **Data sources:** *The EU e-waste recycling public dataset was downloaded from Kaggle.*

- **Data type:** *Structured data organized in a .csv file*

- **Credibility:** *The data seems reliable. However, we should note potential sampling or data-entry errors.*

**Plan:**

- Clean dataset with R

- Use R Studio to process, analyze, and visualize the data.

- Use R Markdown to save project.

**Data Analysis**

**Possible questions:**
1. Percentage of e-waste recycled over time?
2. Which country recycled the most/least e-waste in a given year?
3. Are there upward or downward trends in e-waste recycling across countries?
4. Which countries are experiencing the fastest growth in e-waste recycling?
5. How do countries compare in terms of e-waste recycling?
6. Which countries might benefit from improved e-waste management policies?

**Key Findings:**

**Overall Recycling Performance: EU vs Global Trends**

Between **2008** and **2018**, the EU's average e-waste recycling rate was **35.6%**, over twice the global rate of **17.4% in 2019**.
This suggests EU policies like the WEEE Directive have been relatively effective.
By **2019**, Europe's rate rose to **42.5%**, showing continued progress.

**Plot Findings**

**Trends and Policy Impact**

The EU's e-waste recycling rate dipped in **2009**, likely due to the financial crisis, but rose steadily from **2010** onward.
This growth reflects effective policies like the WEEE Directive and better recycling infrastructure.
To sustain progress, stronger enforcement, technological innovation, and public engagement are essential.

**Disparities in EU Country Performance**

- In the bar chart, Croatia leads with a significantly higher rate above **80%** than the 10th-ranked country(Germany).
  Croatia, Denmark, the UK, and Bulgaria exceed the EU target **(65%)**, but Germany falls short **(<50%)**.
  The range is wide **(>80% and <50%)**, suggesting uneven e-waste management policies across the EU.

- The heatmap shows e-waste recycling rates **(2008–2018)** for 28 EU countries, with deeper green indicating higher performance.
**Croatia and Bulgaria** steadily improved from **2012–2018**, reflecting strong policies.
**Sweden** saw a sharp rise until **2014**, followed by a decline, possibly due to policy or reporting changes.
Most countries remained near **25%**, indicating ongoing challenges not explained by the heatmap alone.
- For the Top vs Bottom performance, Bulgaria performed better, whilst Malta performed poorly.

**Conclusions**

The EU’s **2008–2018** e-waste trends highlight policy-driven progress but also reveal vulnerabilities like economic sensitivity and uneven adoption.
Europe’s **2019 rate of 42.5% and 16.2 kg/capita waste** underscores both leadership and the scale of the challenge.
Global efforts should replicate successful models like **Croatia’s** and tackle systemic policy and economic barriers.
