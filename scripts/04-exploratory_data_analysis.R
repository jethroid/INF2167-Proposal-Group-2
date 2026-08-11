#### Preamble ####
# Purpose: Further Experiments With Merged Dataset
# Author: Jet McCullough
# Date: 11 August 2026

library(tidyverse)
library(here)
library(janitor)
library(tinytable)
library(scales)
library(fs)
library(hrbrthemes)

newselec <- read_csv(here("data", "02-analysis_data", "news_election.csv"))
withdupes <- read_csv(here("data", "02-analysis_data", "news_election_before_dupe_removal.csv"))

# look at the types of media affected by negative changes

withdupes |>
  group_by(media_type) |>
  summarize(neg_number = -sum(type_val[type_val == -1])/3) |>
  arrange(desc(neg_number)) |>
  tt(caption = "Media Types With The Most Negative News Changes", colnames = FALSE, width = 1) |>
  style_tt(i = "caption", bold = TRUE) |>
  style_tt(i=1, j=2, background = "#FFADAD") |>
  style_tt(i=6:9, j=2, background = "#FFE0E0") |>
  style_tt(i=2:5, j=2, background = "#FFC2C2")

# look at the most negative changes by riding alongside lowest turnout in 2021 election

# make table of worst news changes as of 2021

badnews <- newselec |>
  filter(election_year == 2021) |>
  select(fedename, cumulative_news) |>
  arrange(cumulative_news) |>
  slice_head(n=23)

# save vector of top names
newsnames <- pull(badnews, fedename)

badnews |>
  tt(caption = "Ridings With The Most Negative News Impact Score", colnames = FALSE) |>
  style_tt(i = "caption", bold = TRUE) |>
  style_tt(i=1:5, j=2, background = "#F5C7FF") |>
  style_tt(i=13:23, j=2, background = "#FCEBFF") |>
  style_tt(i=6:12, j=2, background = "#F9DBFF")|>
  style_tt(i=12, j=1, background = "#D1DAFF") |>
  style_tt(i=15, j=1, background = "#D1DAFF") |>
  style_tt(i=20, j=1, background = "#D1DAFF")
  
# make table of lowest turnout relative to ntl. avg.

lowturn <- newselec |>
  filter(election_year == 2021) |>
  select(fedename, turnout_diff) |>
  arrange(turnout_diff) |>
  mutate(turnout_diff = percent(turnout_diff, accuracy = 0.1)) |>
  slice_head(n=23)

# save vector of top names
turnnames <- pull(lowturn, fedename)

lowturn |>
  tt(caption = "Ridings With The Lowest Turnout Relative to National Average", colnames = FALSE) |>
  style_tt(i = "caption", bold = TRUE) |>
  style_tt(i=1:5, j=2, background = "#FFDB9E") |>
  style_tt(i=13:23, j=2, background = "#FFF6E5") |>
  style_tt(i=6:12, j=2, background = "#FFEBC7") |>
  style_tt(i=23, j=1, background = "#D1DAFF") |>
  style_tt(i=15, j=1, background = "#D1DAFF") |>
  style_tt(i=19, j=1, background = "#D1DAFF") 

#double check ridings in common, retroactively coloured in above

intersect(newsnames, turnnames)

# examine positive changes, create graph

colours <- c("#008A45", "#CCA500", "#A80084", "#295BFF", "#A30500")

newselec |>
  filter(election_year == 2021) |>
  select(fedename, cumulative_news) |>
  arrange(desc(cumulative_news)) |>
  slice_head(n=5) |>
  ggplot(aes(x = reorder(fedename, -cumulative_news), y = cumulative_news, fill = fedename)) +
  geom_col(show.legend = FALSE) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, size = 10, vjust = 1, face = "bold")) +
  scale_fill_manual(values = colours) +
  scale_x_discrete(labels = c("London North Centre" = "London \n North Centre",
                              "Esquimalt--Saanich--Sooke" = "Esquimalt--\n Saanich--Sooke",
                              "Scarborough--Guildwood" = "Scarborough--\n Guildwood")) +
  labs(
    x = NULL,
    y = "News Score",
    caption = "Figure 5.2.1. Ridings with the highest news scores."
  )
