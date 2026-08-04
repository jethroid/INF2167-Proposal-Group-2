# Visuals for Class Presentation

library(here)
library(tidyverse)
library(hrbrthemes)

news <- read.csv(here("data", "01-raw_data", "paper_data", "local_news.csv"))

head(news)

# colour pallette from https://github.com/johannesbjork/LaCroixColoR
colours <- c(
  "closed" = "#EE4244FF",
  "shifted to online" = "#F8D961FF",
  "closed due to merger" = "#F8D961FF",
  "decrease in service" = "#F8D961FF",
  "new" = "#3C5541FF",
  "increase in service" = "#638E6EFF",
  "new outlet produced by merger" = "#B6D944FF",
  "daily becomes a community paper" = "#B6D944FF"
)

news |>
  rename(transition = 'Transition.Type') |>
  group_by(transition) |>
  summarize("Number_of_Transitions" = n()) |>
  ggplot(aes(x= reorder(transition, -Number_of_Transitions), y= Number_of_Transitions, fill= transition)) +
  geom_col(show.legend = FALSE) +
  theme_ipsum() +
  scale_fill_manual(values = colours) +
  labs(
    x = "Transition Type",
    y = "Number of Transitions"
  )