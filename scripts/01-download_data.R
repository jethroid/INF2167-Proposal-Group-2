#### Preamble ####
# Purpose: Download and save census, elections, and news data.
# Author: Jet McCullough

# loading R packages
library(tidyverse)
library(here)
library(readxl)
library(fs)

# downloading news data, converting to .csv
xlpath = here("data", "01-raw_data", "paper_data", "local_news.xlsx")
csvpath = here("data", "01-raw_data", "paper_data", "local_news.csv")
download.file("https://s35582.pcdn.co/wp-content/uploads/2026/06/June-8-2026-raw-data.xlsx",
  destfile = xlpath,
  mode = "wb")
news_data <- read_excel(xlpath, sheet = 2)
write_csv(news_data, csvpath)

# downloading elections data, saving csvs in election year folders
unpath = here("data", "01-raw_data", "paper_data", "year")
zpath = here("data", "01-raw_data", "paper_data", "year.zip")
years <- list("2021", "2019", "2015")
form1 <- list(
  "https://www.elections.ca/res/rep/off/ovr2021app/53/data_donnees/pollbypoll_bureauparbureauCanada.zip",
  "https://www.elections.ca/res/rep/off/ovr2019app/51/data_donnees/pollbypoll_bureauparbureauCanada.zip",
  "https://www.elections.ca/res/rep/off/ovr2015app/41/data_donnees/pollbypoll_bureauparbureauCanada.zip")
for (i in seq_along(form1)) {
  download.file(form1[[i]], destfile = zpath, mode = "wb")
  unzip(zpath, exdir = unpath)
  file.rename(from = unpath, to = here("data", "01-raw_data", "paper_data", years[[i]]))
}

# removing table files from 2015 election data
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau01.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau02.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau03.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau04.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau05.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau06.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau07.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau08.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau09.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau10.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau11.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau12.csv"))
unlink(here("data", "01-raw_data", "paper_data", "2015", "table_tableau13.csv"))


# downloading electoral district boundary shape files
unpath = here("data", "01-raw_data", "geography", "2021")
zpath = here("data", "01-raw_data", "geography", "2021.zip")
download.file("https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lfed000b21a_e.zip", destfile = zpath, mode = "wb")
unzip(zpath, exdir = unpath)
