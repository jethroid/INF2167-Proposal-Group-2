#### Preamble ####
# Purpose: New Turnout and Media Change Variables
# Author: Jet McCullough
# Date: 8 August 2026

library(tidyverse)
library(here)
library(janitor)
library(lubridate)

#loading merged data from step 2
newselec <- read_csv(here("data", "02-analysis_data", "news_election.csv"))


##get total and relative turnout for election years##

#download report
dir.create(here("data", "01-raw_data", "turnout"), recursive = TRUE, showWarnings = FALSE)

download.file("https://www.elections.ca/res/rep/off/ovr2021app/53/data_donnees/table_tableau04.csv",
              destfile = here("data", "01-raw_data", "turnout", "turnout.csv"),
              mode = "wb")

#save national turnout per year
turn <- read_csv(here("data", "01-raw_data", "turnout", "turnout.csv"))

#total all prov. per year
turn <- adorn_totals(turn, where = "row", name = "total")

#just totals
tots <- as.numeric(turn[14,])
turnouts <- c(tots[6]/tots[2], tots[7]/tots[3], tots[8]/tots[4])

#add national turnout to our data
newselec <- newselec |> 
  mutate(national_turnout = case_when(
    election_year == 2021 ~ turnouts[1],
    election_year == 2019 ~ turnouts[2],
    election_year == 2015 ~ turnouts[3]
  ))

#add turnout difference
newselec <- newselec |>
  mutate(turnout_diff = turnout - national_turnout)


## Add variable for news changes between election years ##

neg_change <- c("closed", "shifted to online", "closed due to merger", "decrease in service")
pos_change <- c("new", "increase in service")

newselec <- newselec |>
  rename(change_type = "Transition Type") |>
  rename(change_date = "Date of Change") |>
  
  # establishing types of changes
  mutate(type_val = case_when(
    change_type %in% neg_change ~ -1,
    change_type %in% pos_change ~ 1,
    TRUE ~ 0
  ))


newselec <- newselec |>
  mutate(
    change_date = ymd(change_date),
    
    # create a new column with the exact date of the election for that year
    election_date = case_when(
      election_year == 2015 ~ ymd("2015-10-19"),
      election_year == 2019 ~ ymd("2019-10-21"),
      election_year == 2021 ~ ymd("2021-09-19"))) |>
  
  # group by both the riding and election year
  group_by(fed_code, election_year) |>
  
  # calculate the cumulative change of local news for the riding up to the election date
  mutate(
    cumulative_news = sum(type_val[change_date <= election_date], na.rm = TRUE)) |>
  ungroup() |>
  
  # remove duplicated riding rows
  distinct(fed_code, election_year, .keep_all = TRUE)

# check key statistics of cumulative change of news and turnout difference
summary(newselec$cumulative_news)

summary(newselec$turnout_diff)

# tidy names
newselec <- newselec |>
  clean_names()

write_csv(newselec, here("data", "02-analysis_data", "news_election.csv"))
