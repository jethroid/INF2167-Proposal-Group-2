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
library(fs)

#### Spatial Data ####
# import spatial data with simple feature package
fed_boundaries <- st_read(
  here("data", "01-raw_data", "geography", "2021", "lfed000b21a_e.shp"))

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

# listing all csvs for a given year using ls package
paths2021 <- dir_ls(path = here("data", "01-raw_data", "paper_data", "2021"))
paths2019 <- dir_ls(path = here("data", "01-raw_data", "paper_data", "2019"))
paths2015 <- dir_ls(path = here("data", "01-raw_data", "paper_data", "2015"))

# remove uncommon variables i.e. candidate names
remnam <- function(data) {
  read_csv(data) |>
  select("Electoral District Number/Numéro de circonscription",
        "Electoral District Name/Nom de circonscription",
        "Total Votes/Total des votes",
        "Electors/Électeurs")|>
  write_csv(data)}

map(paths2021, remnam)
map(paths2019, remnam)
map(paths2015, remnam)

# load election results                 
election_2021 <- read_csv(paths2021)
election_2019 <- read_csv(paths2019)
election_2015 <- read_csv(paths2015)

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
election_2021_fed <- calculate_turnout(election_2021, 2021)

election_2019_fed <- calculate_turnout(election_2019, 2019)

election_2015_fed <- calculate_turnout(election_2015, 2015)

# combine all election data
election_all <- bind_rows(
  election_2021_fed,
  election_2019_fed,
  election_2015_fed
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
