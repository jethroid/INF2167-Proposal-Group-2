#### Preamble ####
# Purpose: New Turnout and Media Change Variables
# Author: Jet McCullough
# Date: 8 August 2026

library(tidyverse)
library(here)
library(janitor)

#loading merged data from step 2
newselec <- read_csv(here("data", "02-analysis_data", "news_election.csv"))

##get total and relative turnout for election years##

#download report
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
write_csv(newselec, here("data", "02-analysis_data", "news_election.csv"))