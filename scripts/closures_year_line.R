# Visuals for Class Presentation

library(here)
library(tidyverse)
library(hrbrthemes)

news <- read_csv(here("data", "01-raw_data", "paper_data", "local_news.csv"))

news <- news |>
  rename(transition = "Transition Type") |>
  rename(date_of_change = "Date of Change") |>
  filter(transition == "closed") |>
  mutate(date_of_change = year(mdy(date_of_change)))

news |>
  group_by(date_of_change) |>
  count() |>
  ungroup() |>
  filter(date_of_change != 2026, date_of_change != 2008) |>
  ggplot(aes(x = date_of_change, y = n)) +
  geom_line(colour = "maroon", linewidth = 1, alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE, color = "navy") +
  theme_ipsum() +
  scale_x_continuous(breaks = scales::pretty_breaks(n=7)) +
  labs(x = "Year", y = "Number of Outlet Closures", title = "Local News Closures, 2009-2025")

view(news)