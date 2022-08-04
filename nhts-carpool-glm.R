library(tidyverse)

data = read_csv("data/nhts/carpool.csv")

glm_model = glm(carpool~hhsize+cars_per_driver+commute+social,
    family=binomial(link="logit"), data)
summary(glm_model)

