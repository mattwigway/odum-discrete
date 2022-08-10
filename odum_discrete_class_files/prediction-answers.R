# adjust travel times
database = mutate(
    original_database,
    time_rail=time_rail*0.75
    )

# re-load inputs
apollo_inputs = apollo_validateInputs()

# Make predictions
fast_rail_predictions =
    apollo_prediction(model, apollo_probabilities, apollo_inputs)

# compute market shares
fast_rail_mktshares = apply(fast_rail_predictions[,c("car", "rail", "air", "bus")], 2, mean)
fast_rail_mktshares

# compute differences
# if you need to recalculate orig_mktshares, make sure
# you re-run apollo_validateInputs before calculating
fast_rail_mktshares - orig_mktshares

