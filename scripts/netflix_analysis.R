############################################
# Netflix Data Analysis Project - R Script
# Author: YOUR NAME
# Description: Cleaning, exploring, and 
# visualizing Netflix titles dataset
############################################

# ----------------------------
# 1. Load Libraries
# ----------------------------
library(tidyverse)

# ----------------------------
# 2. Load Dataset
# ----------------------------
df <- read_csv("data/netflix_titles_nov_2019.csv")

# ----------------------------
# 3. Keep important columns
# ----------------------------
df <- df %>% 
  select(show_id, type, title, release_year, duration)

# ----------------------------
# 4. Extract numeric duration
# ----------------------------
df <- df %>% 
  mutate(duration_num = as.numeric(str_extract(duration, "\\d+")))

# ----------------------------
# 5. Save cleaned dataset
# ----------------------------
write_csv(df, "data/clean_netflix.csv")

# ----------------------------
# 6. Exploratory Data Analysis
# ----------------------------

# 6.1 Average movie duration
avg_movie_duration <- df %>% 
  filter(type == "Movie") %>% 
  summarize(avg_duration = mean(duration_num, na.rm = TRUE))

print(avg_movie_duration)

# 6.2 Which year released the most content?
content_by_year <- df %>% 
  count(release_year, sort = TRUE)

print(content_by_year)

# 6.3 Longest Movie and Longest TV Show
longest <- df %>% 
  group_by(type) %>% 
  slice_max(duration_num)

print(longest)

# ----------------------------
# 7. Visualization
# ----------------------------

# 7.1 Movie releases per year
movie_plot <- df %>%
  filter(type == "Movie") %>% 
  count(release_year) %>% 
  ggplot(aes(release_year, n)) +
  geom_col(fill = "red") +
  labs(
    title = "Movies Released Per Year",
    x = "Year",
    y = "Number of Movies"
  ) +
  theme_minimal()

ggsave("plots/movies_by_year.png", movie_plot, width = 8, height = 5)

# ----------------------------
# 8. Clustering (Bonus)
# ----------------------------

# Remove missing values for clustering
cluster_df <- df %>% 
  filter(!is.na(duration_num)) %>% 
  select(duration_num, release_year)

# Perform k-means
set.seed(42)
clusters <- kmeans(cluster_df, centers = 3)

cluster_df$cluster <- as.factor(clusters$cluster)

# Plot clusters
cluster_plot <- ggplot(cluster_df, aes(duration_num, release_year, color = cluster)) +
  geom_point(alpha = 0.7) +
  labs(
    title = "K-Means Clustering of Netflix Titles",
    x = "Duration (minutes/seasons)",
    y = "Release Year"
  ) +
  theme_minimal()

ggsave("plots/clustering_plot.png", cluster_plot, width = 8, height = 5)

############################################
# End of Script
############################################