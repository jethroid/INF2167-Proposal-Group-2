# R script to download and save census, elections, and news data.

# loading R packages
library(tidyverse)
library(here)
library(readxl)
library(readr)

# downloading news data, converting to .csv
xlpath = here("data", "01-raw_data", "paper_data", "local_newst.xlsx")
csvpath = here("data", "01-raw_data", "paper_data", "local_newst.csv")
download.file("https://s35582.pcdn.co/wp-content/uploads/2026/06/June-8-2026-raw-data.xlsx",
  destfile = xlpath,
  mode = "wb")
news_data <- read_excel(xlpath, sheet = 2)
write_csv(news_data, csvpath)

# downloading elections data, saving csvs in election year folders
unpath = here("data", "01-raw_data", "paper_data", "electtest", "year")
zpath = here("data", "01-raw_data", "paper_data", "electtest", "year.zip")
years <- list("2025", "2021", "2019", "2015", "2011", "2008")
form1 <- list("https://www.elections.ca/res/rep/off/ovrGE45/62/data_donnees/pollbypoll_bureauparbureauCanada.zip",
  "https://www.elections.ca/res/rep/off/ovr2021app/53/data_donnees/pollbypoll_bureauparbureauCanada.zip",
  "https://www.elections.ca/res/rep/off/ovr2019app/51/data_donnees/pollbypoll_bureauparbureauCanada.zip",
  "https://www.elections.ca/res/rep/off/ovr2015app/41/data_donnees/pollbypoll_bureauparbureauCanada.zip",
  "https://www.elections.ca/scripts/OVR2011/34/data_donnees/pollbypoll_bureauparbureau_canada.zip",
  "https://www.elections.ca/scripts/OVR2008/31/data/pollbypoll_bureauparbureau_canada.zip")
for (i in seq_along(form1)) {
  download.file(form1[[i]], destfile = zpath, mode = "wb")
  unzip(zpath, exdir = unpath)
  file.rename(from = unpath, to = here("data", "01-raw_data", "paper_data", "electtest", years[[i]]))
}

