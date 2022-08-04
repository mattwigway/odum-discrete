library(apollo)
library(tidyverse)

database = read_csv("data/modechoice.csv")

apollo_initialise()

apollo_control = list(
    modelName = "Australia_Mode_Choice",
    indivID="individual"
)

head(database)

apollo_beta = c(
    asc_air = 0,
    asc_bus = 0,
    asc_train = 0,
    # leaving out an asc_car as base category
    # wait_time varies across alternatives, so we can have a
    # single wait_time coefficient
    b_wait_time = 0,
    b_cost = 0,
    b_in_vehicle_time = 0,
    # income and party_size are individual level variable, so
    # must be different for different alternatives
    b_hhincome_air = 0,
    b_hhincome_bus = 0,
    b_hhincome_train = 0,
    b_party_size_air = 0,
    b_party_size_bus = 0,
    b_party_size_train = 0
)

apollo_fixed = c()

apollo_inputs = apollo_validateInputs()

apollo_probabilities = function(apollo_beta, apollo_inputs,
        functionality="estimate") {
    apollo_attach(apollo_beta, apollo_inputs)
    on.exit(apollo_detach(apollo_beta, apollo_inputs))

    P = list()

    # define utility functions
    V = list()
    # We can include cost and in-vehicle time here because they vary over
    # alternatives
    V[["car"]] = b_cost * cost_car +
        b_in_vehicle_time * in_vehicle_time_car
    # Exercise: why can't we include wait time in utility of car?

    V[["air"]] = asc_air +
        b_cost * cost_air +
        b_in_vehicle_time * in_vehicle_time_air +
        b_wait_time * wait_time_air +
        b_hhincome_air * hhincome_thousands +
        b_party_size_air * party_size

    V[["train"]] = asc_train +
        b_cost * cost_train +
        b_in_vehicle_time * in_vehicle_time_train +
        b_wait_time * wait_time_train +
        b_hhincome_train * hhincome_thousands +
        b_party_size_train * party_size

    V[["bus"]] = asc_bus +
        b_cost * cost_bus +
        b_in_vehicle_time * in_vehicle_time_bus +
        b_wait_time * wait_time_bus +
        b_hhincome_bus * hhincome_thousands +
        b_party_size_bus * party_size

    mnl_settings = list(
        alternatives = c(car="car", air="air", train="train", bus="bus"),
        avail = list(car=T, air=T, train=T, bus=T),
        choiceVar = chosen,
        utilities = V
    )

    P[["model"]] = apollo_mnl(mnl_settings, functionality)
    P = apollo_prepareProb(P, apollo_inputs, functionality)
    return(P)
}

# estimate model
model = apollo_estimate(apollo_beta, apollo_fixed,
    apollo_probabilities, apollo_inputs)

# Print results
apollo_modelOutput(model)

