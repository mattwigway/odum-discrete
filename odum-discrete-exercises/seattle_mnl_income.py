import biogeme.database as db, biogeme.biogeme as bio
from biogeme import models
from biogeme.expressions import Beta, Variable
import pandas as pd

df = pd.read_csv("data/seattle_trips.csv") # read data

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
b_income_over_100k_bike = Beta("b_income_over_100k_bike", 0, None, None, 0)

asc_walk = Beta("asc_walk", 0, None, None, 0)
b_income_over_100k_walk = Beta("b_income_over_100k_walk", 0, None, None, 0)

asc_transit = Beta("asc_transit", 0, None, None, 0)
b_income_over_100k_transit = Beta("b_income_over_100k_transit", 0, None, None, 0)

# and specify the variables we want to use
income_over_100k = Variable("income_over_100k")

V = {
    # Car
    1: 0,

    # Transit
    2: asc_transit + b_income_over_100k_transit * income_over_100k,

    # Walk
    3: asc_walk + b_income_over_100k_walk * income_over_100k,

    # Bike
    4: asc_bike + b_income_over_100k_bike * income_over_100k
}

av = {1: 1, 2: 1, 3: 1, 4: 1}

logprob = models.loglogit(V, av, Variable("numeric_mode"))

model = bio.BIOGEME(data, logprob)
model.modelName = "seattle_mnl_income"
model.calculate_null_loglikelihood(av)
result = model.estimate()

assert result.algorithm_has_converged()
print(result.short_summary())
print(result.get_estimated_parameters())

