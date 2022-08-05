library(apollo)
library(tidyverse)

database = read_csv("data/modechoice_apollo.csv")

apollo_initialise()

apollo_control = list(
    modelName = "Apollo_Mode_Choice",
    indivID="ID"
)

head(database)

apollo_beta = c(
    asc_air = 0,
    asc_bus = 0,
    asc_rail = 0,
    # leaving out an asc_car as base category
    b_cost = 0,
    b_access_time = 0,
    b_in_vehicle_time = 0,
    # income is an individual level variable, so
    # must be different for different alternatives
    b_income_air = 0,
    b_income_bus = 0,
    b_income_rail = 0
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
        b_in_vehicle_time * time_car

    V[["air"]] = asc_air +
        b_cost * cost_air +
        b_in_vehicle_time * time_air +
        b_access_time * access_air +
        b_income_air * income

    V[["rail"]] = asc_rail +
        b_cost * cost_rail +
        b_in_vehicle_time * time_rail +
        b_access_time * access_rail +
        b_income_rail * income

    V[["bus"]] = asc_bus +
        b_cost * cost_bus +
        b_in_vehicle_time * time_bus +
        b_access_time * access_bus +
        b_income_bus * income

    mnl_settings = list(
        alternatives = c(car=1, air=3, rail=4, bus=2),
        avail = list(car=av_car, air=av_air, rail=av_rail, bus=av_bus),
        choiceVar = choice,
        utilities = V
    )

    P[["model"]] = apollo_mnl(mnl_settings, functionality)

    # For panel data, this multiplies observations for single individuals
    # together - no effect in multinomial logit but still required.
    P = apollo_panelProd(P, apollo_inputs, functionality)
    P = apollo_prepareProb(P, apollo_inputs, functionality)
    return(P)
}

# estimate model
model = apollo_estimate(apollo_beta, apollo_fixed,
    apollo_probabilities, apollo_inputs)

# Print results
apollo_modelOutput(model)

apollo_deltaMethod(model, deltaMethod_settings=list(
    operation="ratio",
    parName1="b_in_vehicle_time",
    parName2="b_cost",
    multPar1=60
))

