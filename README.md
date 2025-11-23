![License](https://img.shields.io/badge/License-MIT-green)
![PostgreSQL](https://img.shields.io/badge/SQL-PostgreSQL-blue)
![R Programming](https://img.shields.io/badge/R-Programming-%23276DC2)
![Data Cleaning](https://img.shields.io/badge/Data--Cleaning-tidyverse-orange)  
![Project Status](https://img.shields.io/badge/Status-Completed-success)
[![R Script](https://img.shields.io/badge/Script-netflix_analysis.R-black)](scripts/netflix_analysis.R)
![Advanced SQL](https://img.shields.io/badge/SQL-Analytical_SQL-purple)

```md
# 🎬 Netflix Data Engineering + R Analysis Project

# A complete end-to-end SQL + R portfolio project using the Netflix Titles Dataset (Nov 2019)

📌 Overview

This repository demonstrates a complete data-engineering + analytics workflow, combining:

🔹 SQL (PostgreSQL)

Schema design

Data cleaning

Views & Materialized Views

Stored procedures

Triggers

Analytical SQL

🔹 R (tidyverse)

Data cleaning

Feature engineering

Visualization

Clustering (k-means)

Exporting cleaned datasets

This project is designed as a high-quality portfolio entry for Data Analyst, SQL Developer, and R Analyst roles.

📂 Project Structure
.
├── ANALYSIS.md
├── .gitignore
│
├── data/
│ ├── netflix_titles_nov_2019.csv
│ ├── clean_netflix.csv
│
├── docs/
│ ├── ER_Diagram.png
│ ├── SQL_Netflix_Project_Detailed.pdf
│
├── plot/
│ ├── Bar_chart_Movie_release_year.png
│ ├── Clustering(A_short_bits_of_ML).png
│ ├── Scatter_plot_duration_by_year.png
│
├── script/
│ ├── netflix_analysis.R
│
└── SQL/
├── 01_schema.sql
├── 02_cleaning.sql
├── 03_views_and_materialized.sql
├── 04_procedures_and_triggers.sql
├── query.sql

🗄️ SQL SECTION
🧱 1. Schema Design (Example SQL)
CREATE TABLE netflix_titles (
show_id INT PRIMARY KEY,
type VARCHAR(20),
title TEXT NOT NULL,
director TEXT,
cast TEXT,
release_year INT CHECK (release_year >= 1900),
duration TEXT,
country TEXT,
date_added DATE
);

✔️ Enforces data quality
✔️ Prevents invalid years
✔️ Ensures primary key integrity

🧹 2. Data Cleaning Example
UPDATE netflix_titles
SET duration = TRIM(REPLACE(duration, 'min', 'minutes'))
WHERE type = 'Movie';

UPDATE netflix_titles
SET country = INITCAP(country)
WHERE country IS NOT NULL;

✔️ Standardized duration format
✔️ Cleaned country names

👁️ 3. View for Yearly Content Growth
CREATE VIEW content_by_year AS
SELECT
release_year,
COUNT(\*) AS total_titles
FROM netflix_titles
GROUP BY release_year
ORDER BY release_year;

⚙️ 4. Trigger Example (Log Inserts)
CREATE TABLE log_table (
log_id SERIAL PRIMARY KEY,
show_id INT,
inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_new_insert()
RETURNS TRIGGER AS $$
BEGIN
INSERT INTO log_table(show_id)
VALUES (NEW.show_id);
RETURN NEW;
END;

$$
LANGUAGE plpgsql;

CREATE TRIGGER log_insert_trigger
AFTER INSERT ON netflix_titles
FOR EACH ROW
EXECUTE FUNCTION log_new_insert();


✔️ Demonstrates practical database automation
✔️ Recruiters love seeing triggers & logging

📘 R DATA ANALYSIS SECTION
🔧 Example of Data Loading & Cleaning
library(tidyverse)

df <- read_csv("data/netflix_titles_nov_2019.csv")

clean_df <- df %>%
  select(show_id, type, title, release_year, duration, date_added) %>%
  mutate(
    duration_num = parse_number(duration),
    type = tolower(type),
    title = str_to_title(title)
  ) %>%
  drop_na()


✔️ Cleaned essential columns
✔️ Extracted numeric duration
✔️ Standardized text formatting

📈 Example Visualization
Movies released per year
df %>%
  filter(type == "movie") %>%
  count(release_year) %>%
  ggplot(aes(release_year, n)) +
  geom_col() +
  labs(title = "Movies Released Per Year",
       x = "Year",
       y = "Count")


✔️ Simple, effective trend analysis

🤖 K-means Clustering Example
cluster_data <- clean_df %>%
  select(duration_num, release_year)

set.seed(42)
km <- kmeans(cluster_data, centers = 3)

clean_df$cluster <- km$cluster

ggplot(clean_df, aes(duration_num, release_year, color = factor(cluster))) +
  geom_point() +
  labs(title = "Movie Clusters by Duration & Release Year")


✔️ Demonstrates ML skills
✔️ Good for analytical roles

💾 Save Clean Data
write_csv(clean_df, "data/clean_netflix.csv")

▶️ How to Run
1️⃣ SQL

Run SQL scripts in order:

01_schema.sql
02_cleaning.sql
03_views_and_materialized.sql
04_procedures_and_triggers.sql
query.sql

2️⃣ R
install.packages("tidyverse")
source("script/netflix_analysis.R")

🎯 Skills Demonstrated
✔️ SQL Engineering

Schema design • Views • MV’s • Triggers • Data Cleaning • Transformations • Joins • Window Functions

✔️ R Analytics

Tidyverse • Feature Engineering • ggplot2 • Clustering • Data Export • Regex

📜 License

MIT License (add LICENSE file).

📬 Contact

If you want advanced SQL analytics or a Shiny dashboard version of this project — feel free to reach out!
$$


Author: Ankit0227 AKA Ankit Parkhe
...
```
