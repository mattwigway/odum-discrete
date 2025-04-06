import biogeme.database as db, biogeme.biogeme as bio
from biogeme import models
from biogeme.expressions import Beta, Variable
import pandas as pd
import numpy as np

df = pd.read_csv("data/seattle_trips.csv") # read data

# Remove people who chose transit despite transit not being available
df = df.loc[(df.mode_choice != "Transit") | df.transit_available, :]

# create our choice variable - it is coded as text in the data but Biogeme requires
# it to be numeric
df["numeric_mode"] = df.mode_choice.replace({
    "Car": 1,
    "Transit": 2,
    "Walk": 3,
    "Bike": 4
}).astype("int32")

data = db.Database("Seattle", pd.get_dummies(df).astype("float64"))

# specify coefficients - all start at zero, have no bounds (None, None), and are
# estimated rather than fixed (0)
asc_bike = Beta("asc_bike", 0, None, None, 0)

asc_walk = Beta("asc_walk", 0, None, None, 0)

asc_transit = Beta("asc_transit", 0, None, None, 0)

# we only need one coefficient for travel time
b_travel_time = Beta("b_travel_time", 0, None, None, 0)
b_travel_cost = Beta("b_travel_cost", 0, None, None, 0)

V = {
    # Car
    1: 0,

    # Transit
    2: asc_transit,

    # Walk
    3: asc_walk,

    # Bike
    4: asc_bike 
}

av = {1: 1, 2: Variable("transit_available"), 3: 1, 4: 1}

logprob = models.loglogit(V, av, Variable("numeric_mode"))

model = bio.BIOGEME(data, logprob)
model.modelName = "seattle_constants"
model.calculate_null_loglikelihood(av)
result = model.estimate()

assert result.algorithm_has_converged()
print(result.short_summary())
print(result.get_estimated_parameters())

