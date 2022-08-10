library(apollo)
library(tidyverse)

database = read_csv("data/covidfuture_wfh.csv")

apollo_initialise()

apollo_control = list(
    modelName="WFH_Postpandemic",
    indivID="resp_id"
)

head(database)

# now, we must define all the coefficients
# we have separate sets of coefficients for each utility
# function, because the utilities need to be different
apollo_beta = c(
    asc_rarely = 0,
    asc_often = 0,
    asc_always = 0,
    b_rarely_age = 0,
    b_often_age = 0,
    b_always_age = 0,
    b_rarely_highinc = 0,
    b_often_highinc = 0,
    b_always_highinc = 0,
    b_rarely_service_worker = 0,
    b_often_service_worker = 0,
    b_always_service_worker = 0
)

apollo_fixed = c()

apollo_inputs = apollo_validateInputs()

# Finally, we define the utility functions in apollo_probabilities
apollo_probabilities = function(apollo_beta, apollo_inputs,
        functionality="estimate") {
    apollo_attach(apollo_beta, apollo_inputs)
    on.exit(apollo_detach(apollo_beta, apollo_inputs))

    P = list()

    # define utility functions
    V = list()
    # fix one utility to zero
    V[["Unable"]] = 0
    V[["Rarely"]] = asc_rarely + b_rarely_age * age +
        b_rarely_highinc * income_100k_plus +
        b_rarely_service_worker * service_worker
    V[["Often"]] = asc_often + b_often_age * age +
        b_often_highinc * income_100k_plus +
        b_often_service_worker * service_worker
    V[["Always"]] = asc_always + b_always_age * age +
        b_always_highinc * income_100k_plus +
        b_always_service_worker * service_worker
        
    mnl_settings = list(
        alternatives = c(Unable="Unable", Rarely="Rarely",
            Often="Often", Always="Always"),
        avail = list(Unable=T, Rarely=T, Often=T, Always=T),
        choiceVar = wfh,
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

