#### Preamble ####
# Purpose: Linear Regression
# Author: William Chan
# Date: August 9, 2026


#### Workspace setup ####
library(tidyverse)
library(here)
library(modelsummary)

####read data ####
newselec <- read_csv(here("data", "02-analysis_data", "news_election.csv"))

##fit linear regression model##
turnout_model <- lm(turnout_diff ~ cumulative_news, data = newselec)

#print regression summary
modelsummary(turnout_model)

#plot regression results

ggplot(data = newselec, 
       aes(x = cumulative_news, y = turnout_diff)) +
  geom_point(alpha = 0.3, color = "darkgray") +
  
  #overlay the regression line with a 95% confidence interval
  geom_smooth(method = "lm", color = "blue", se = TRUE) +
  labs(
    title = "Effect of Local News Changes on Voter Turnout (2015-2021)",
    x = "Cumulative News Score (Net Change)",
    y = "Turnout Difference from National Average"
  ) +
  
  theme_minimal()


