library(apollo)
library(tidyverse)

# Read data - variable must be called "database"
database = read_csv("data/nhts/carpool.csv")

# Initialize Apollo library
apollo_initialise()

# set parameters for overall model
apollo_control = list(
    modelName="Carpool_binary",
    indivID="id"
)

# In Apollo, you specify your utility functions by hand,
# first telling Apollo what coefficients to estimate
apollo_beta = c(
    constant_carpool = 0, # 0 is starting value
    b_hhsize = 0,
    b_cars_per_driver = 0,
    b_commute = 0,
    b_social = 0
)

# any parameters that you want to remain constant go here
apollo_fixed = c()

# prepare the inputs to the Apollo estimation code
apollo_inputs = apollo_validateInputs()

# this function calculates probabilities of each alternative
apollo_probabilities = function(apollo_beta, apollo_inputs,
        functionality="estimate") {
    # so we can refer to variables by name
    apollo_attach(apollo_beta, apollo_inputs)
    on.exit(apollo_detach(apollo_beta, apollo_inputs))

    # This is the list of probabilities for the alternatives
    # for each observation
    P = list()

    # Define utility functions
    V = list()
    V[["carpool"]] = constant_carpool + b_hhsize * hhsize +
        b_cars_per_driver * cars_per_driver +
        b_commute * commute + b_social * social
    V[["not_carpool"]] = 0

    # associate utility functions with data
    logit_settings = list(
        alternatives = c(carpool=T, not_carpool=F),
        avail        = list(carpool=T, not_carpool=T),
        choiceVar    = carpool,
        utilities    = V
    )

    # compute probabilities
    P[["model"]] = apollo_mnl(logit_settings, functionality)

    P = apollo_prepareProb(P, apollo_inputs, functionality)
    return(P)
}

# finally, estimate the model
model = apollo_estimate(apollo_beta, apollo_fixed,
    apollo_probabilities, apollo_inputs)

# print results
apollo_modelOutput(model)

