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

view(withdupes)