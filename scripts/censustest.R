# downloading census electoral boundary files data:
# can be downloaded by iterating over list of urls like above from https://open.canada.ca/en, or
# accessing cancensus API and saving API token to .Renviron file, 

library(cancensus)
library(sf)

# attempts direct download

unpath = here("data", "01-raw_data", "paper_data", "electtest", "shape")
zpath = here("data", "01-raw_data", "paper_data", "electtest", "shape.zip")
download.file("https://www.elections.ca/res/cir/mapsCorner/vector/FederalElectoralDistricts_2025_SHP.zip", destfile = zpath, mode = "wb")
unzip(zpath, exdir = unpath)
test <- st_read(here("data", "01-raw_data", "paper_data", "electtest", "shape", "SHP", "FED_CA_2025_EN.shp"))
head(test)

# attempts with API

test <- get_census(dataset = "CA21", regions=list(CMA="59933"), geo_format = "sf")

head(test)

#william's code reading .shp file for comparison

test <- st_read(
  here("data", "01-raw_data", "geography", "FED_2021", "FED_2021.shp"))

head(test)
