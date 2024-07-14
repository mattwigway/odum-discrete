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
})

data = db.Database("Seattle", pd.get_dummies(df).astype("float64"))

# specify coefficients - all start at zero, have no bounds (None, None), and are
# estimated rather than fixed (0)
asc_bike = Beta("asc_bike", 0, None, None, 0)
b_income_over_100k_bike = Beta("b_income_over_100k_bike", 0, None, None, 0)
b_rush_hour_bike = Beta("b_rush_hour_bike", 0, None, None, 0)

asc_walk = Beta("asc_walk", 0, None, None, 0)
b_income_over_100k_walk = Beta("b_income_over_100k_walk", 0, None, None, 0)
b_rush_hour_walk = Beta("b_rush_hour_walk", 0, None, None, 0)

asc_transit = Beta("asc_transit", 0, None, None, 0)
b_income_over_100k_transit = Beta("b_income_over_100k_transit", 0, None, None, 0)
b_rush_hour_transit = Beta("b_rush_hour_transit", 0, None, None, 0)

# we only need one coefficient for travel time
b_travel_time = Beta("b_travel_time", 0, None, None, 0)

# and specify the variables we want to use
income_over_100k = Variable("income_over_100k")
rush_hour = Variable("rush_hour")

# but we need the travel time variables for each mode
car_travel_time_mins = Variable("car_travel_time_mins")
bike_travel_time_mins = Variable("bike_travel_time_mins")
walk_travel_time_mins = Variable("walk_travel_time_mins")
transit_travel_time_mins = Variable("transit_travel_time_mins")

V = {
    # Car
    1: b_travel_time * car_travel_time_mins,

    # Transit
    2: asc_transit + b_income_over_100k_transit * income_over_100k + b_rush_hour_transit * rush_hour + b_travel_time * transit_travel_time_mins,

    # Walk
    3: asc_walk + b_income_over_100k_walk * income_over_100k + b_rush_hour_walk * rush_hour + b_travel_time * walk_travel_time_mins,

    # Bike
    4: asc_bike + b_income_over_100k_bike * income_over_100k + b_rush_hour_bike * rush_hour + b_travel_time * bike_travel_time_mins
}

av = {1: 1, 2: Variable("transit_available"), 3: 1, 4: 1}

logprob = models.loglogit(V, av, Variable("numeric_mode"))

model = bio.BIOGEME(data, logprob)
model.modelName = "seattle_mnl_generic"
model.calculateNullLoglikelihood(av)
result = model.estimate()

assert result.algorithm_has_converged()
print(result.shortSummary())
print(result.getEstimatedParameters())

