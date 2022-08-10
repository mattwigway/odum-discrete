# Run this file after running mode-choice-mnl-in-vehicle-answers.R

# Make predictions for the existing dataset
predictions = apollo_prediction(model, apollo_probabilities, apollo_inputs)

# Now, make predictions in a counterfactual scenario
# First, we will give the original database a new name
original_database = database

# then, we will adjust the cost_air column to add a 25 pound tax
# any time air is available
database = mutate(
    original_database,
    cost_air=ifelse(av_air, cost_air + 25, cost_air)
    )

# now that we have a new variable called "database," we run
# apollo_validateInputs again, and then apollo_probabilities
# apollo_validateInputs will always use the variable called
# "database"
apollo_inputs = apollo_validateInputs()
tax_predictions = apollo_prediction(model, apollo_probabilities, apollo_inputs)

# now, we can use the two predictions to compute changes in market shares
# first, original market shares
orig_mktshares = apply(predictions[,c("car", "rail", "air", "bus")], 2, mean)
orig_mktshares

# next, taxed market shares
tax_mktshares = apply(tax_predictions[,c("car", "rail", "air", "bus")], 2, mean)
tax_mktshares

# and finally, their difference. Is this the change we
# expect to see?
tax_mktshares - orig_mktshares

