# Run this after running mode-choice-mnl-in-vehicle-answers.R and predictions.R

# First, we will add 0.01 to the in-vehicle travel time by car
database =
    mutate(original_database, time_car=ifelse(av_car, time_car + 0.01, time_car))

# re-read inputs
apollo_inputs = apollo_validateInputs()

meff_predictions =
    apollo_prediction(model, apollo_probabilities, apollo_inputs)

# now, we can compute the per-observation marginal effect
# We divide by 0.01 to scale the marginal effects to a unit
# change in the independent variable, because this is the
# amount we added above
obs_meff = (meff_predictions - predictions) / 0.01

# now, we average to get the average marginal effect
apply(obs_meff[,c("car", "bus", "rail", "air")], 2, mean)

