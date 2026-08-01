#### Preamble ####
# Purpose: 
# Author: Jet McCullough
# Date: June 18, 2026

#### Workspace setup ####
library(tidyverse)
library(here)

#### Read data ####
news <- read_csv(here("data", "01-raw_data", "proposal_data",  "news_apr_2026.csv")) #opening our datasets
election2025 <- read_csv(here("data", "01-raw_data", "proposal_data",  "2025polls", "pollresults_resultatsbureau24070.csv")) #Saint-Maurice--Champlain riding
format2025 <- read_csv(here("data", "01-raw_data", "proposal_data",  "2025pollsformat1", "pollbypoll_bureauparbureau24070.csv")) #alt. format

### EDA ####
news |>
  group_by(`Transition Type`) |> #counting each type of closure, opening, shifting in service, etc.
  count()|>
  ungroup() |>
  rename(Total = n) |>
  arrange(desc(Total))

torontonews <- news |> #new dataset: negative changes in Toronto
  filter(Community == "Toronto, Ontario") |>
  filter(`Transition Type` != "new" & `Transition Type` != "increase in service") 
torontonews |> 
  mutate(
    date = year(as.Date(torontonews$`Date of Change`))) |> #simplifying to year-by-year
  group_by(date) |> #getting no. of observations per year
  count() |>
  ungroup() |>
  ggplot(aes(x = date, y = n)) + 
  geom_line(colour = "navy") + #lineplot, choosing colour
  scale_x_continuous(breaks = scales::pretty_breaks(n=9)) +
  labs(x = "Year", y = "Number of Negative Changes", 
       title = "Local News Sources Lost or Reduced in Toronto")

election2025 |> #vote totals for parties
  group_by(`Political Affiliation Name_English/Appartenance politique_Anglais`) |>
  summarize(vote_total = sum(`Candidate Vote Count/Votes du candidat`))|>
  ungroup() |>
  mutate(vote_share = vote_total/sum(vote_total)) |>
  rename(Party = `Political Affiliation Name_English/Appartenance politique_Anglais`) |>
  filter(vote_share < 0.015) |> #only small parties, 1.5% chosen arbitrarily
  arrange(vote_total) #arranging by least votes to most

format2025 |>
  mutate(turnout = `Total Votes/Total des votes`/`Electors/Électeurs`) |> #calculating turnout
  ggplot(aes(x = turnout)) +
  geom_histogram(bins = 60, fill = "purple") + #histogram of turnout levels
  scale_x_log10() + #scale for readability
  labs(x = "Turnout", 
       y = "Number of Polls", 
       title = "Distribution of Turnout in Saint-Maurice--Champlain Riding")

format2025 |>
  filter(`Total Votes/Total des votes` > `Electors/Électeurs`)|> #what are these over 100% turnout polls?
  select(c(`Polling Division Name/Nom de section de vote`, `Total Votes/Total des votes`, `Electors/Électeurs`))


