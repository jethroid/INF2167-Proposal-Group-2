# Visuals for Class Presentation

library(here)
library(tidyverse)
library(hrbrthemes)
library(tinytable)

news <- read_csv(here("data", "02-analysis_data", "news_election.csv"))

ajax <- news |>
  filter(election_year != "NA") |>
  rename(transition_type = "Transition Type") |>
  rename(date_of_change = "Date of Change") |>
  select(FEDENAME, title, transition_type, date_of_change, election_year, turnout)

tt(ajax)