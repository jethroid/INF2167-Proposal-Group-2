#### Preamble ####
# Purpose: Clean and Merge datasets
# Author: William Chan
# Date: 1 August 2026

#### Workspace setup ####
library(tidyverse)
library(here)
library(sf)
library(tinytable)
library(scales)

#### Spatial Data ####
# import spatial data with simple feature package
fed_boundaries <- st_read(
  here("data", "01-raw_data", "geography", "FED_2021", "FED_2021.shp"))

# rename federal electoral district ID column
fed_boundaries <- fed_boundaries |>
  rename(FEDDGUID_CEFIDUGD = DGUID) |>
  select(FEDDGUID_CEFIDUGD,FEDENAME,PRUID,geometry) # filter columns of interests

### Local News Data ###
# load local news data
news <- read_csv((here("data", "01-raw_data", "paper_data",  "local_news.csv")))

# split the coordinates in news data into latitude and longitude
news <- news |>
  separate(coordinates,
           into = c("latitude", "longitude"),
           sep = ", ",
           convert = TRUE
  )

# convert news data into spatial data with the coordinates, and assign 4326 (WGS84) as reference coordinate system
news_sf <- st_as_sf(news, coords = c("longitude", "latitude"), crs = 4326)

# align the coordinate system of news data with the federal electoral district boundaries data
news_sf <- st_transform(news_sf, st_crs(fed_boundaries))

# merge the news data with federal electoral district boundaries data
# if a point (address of local news) is located within a polygon (federal boundaries), it will be assigned the corresponding district ID and name 
news_fed <- st_join(news_sf, fed_boundaries, join = st_within)

# check unmatched result that has no district ID assigned
news_fed |>
  filter(is.na(FEDDGUID_CEFIDUGD)) |>
  select(title, Community, geometry)

# manually correct the coordinates for the unmatched data
new_point <- st_sfc(
  st_point(c(-123.11413726425735, 49.27975314823103)), crs = 4326) |>
  st_transform(st_crs(news_sf))

news_sf$geometry[
  news_sf$title == "Radio-Canada TV - Vancouver"
] <- new_point[[1]]

# ensure coordinate system equals to the federal boundaries file
news_sf <- st_transform(
  news_sf,
  st_crs(fed_boundaries)
)

# merge again
news_fed <- st_join(news_sf, fed_boundaries, join = st_within)


### Elections data ###
# load election results
election_2025 <- read_csv((here("data", "01-raw_data", "paper_data",  "election_2025_ajax.csv")))
election_2021 <- read_csv((here("data", "01-raw_data", "paper_data",  "election_2021_ajax.csv")))
election_2019 <- read_csv((here("data", "01-raw_data", "paper_data",  "election_2019_ajax.csv")))

# create a function to clean election data
calculate_turnout <- function(data, year) {
  
  # rename columns
  data |>
    rename(
      fed_code = "Electoral District Number/Numéro de circonscription",
      fed_name = "Electoral District Name/Nom de circonscription",
      votes = "Total Votes/Total des votes",
      electors = "Electors/Électeurs") |>
    
    # convert vote and elector counts as numeric type
    mutate(votes = as.numeric(votes), electors= as.numeric(electors)) |>
    
    # get turnout rate for each electoral district
    group_by(fed_code) |>
    summarise(
      total_votes = sum(votes, na.rm = TRUE),   # calculate sum of votes
      electors = sum(electors, na.rm = TRUE)) |> # calculate sum of electors
    ungroup() |>
    
    # calculate turnout rate
    mutate(turnout = total_votes / electors, election_year = year)
}

# get turnout rate for each election
election_2025_fed <- calculate_turnout(election_2025, 2025)

election_2021_fed <- calculate_turnout(election_2021, 2021)

election_2019_fed <- calculate_turnout(election_2019, 2019)

# combine all election data
election_all <- bind_rows(
  election_2025_fed,
  election_2021_fed,
  election_2019_fed
)

# transform id column for merging two datasets
news_fed <- news_fed |>
  mutate(
    fed_code = substr(
      FEDDGUID_CEFIDUGD,
      nchar(FEDDGUID_CEFIDUGD) - 4,
      nchar(FEDDGUID_CEFIDUGD)
    )
  )

# ensure id have the same data type for merging
news_fed <- news_fed |>
  mutate(fed_code = as.character(fed_code))

election_all <- election_all |>
  mutate(fed_code = as.character(fed_code))

news_election <- news_fed |>
  left_join(election_all, by = "fed_code")

#### Save data ####
write_csv(
  st_drop_geometry(news_election),
  here("data", "02-analysis_data", "news_election.csv")
)
