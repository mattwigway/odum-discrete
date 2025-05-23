import biogeme.database as db, biogeme.biogeme as bio
from biogeme import models
from biogeme.expressions import Beta, Variable
import pandas as pd

df = pd.read_csv("data/wfh_prediction_covidfuture.csv") # read data
data = db.Database("WFH", 
    pd.get_dummies(df)
        .drop(columns="gender_Female")
        .astype("float64")
) # convert to Biogeme format

# specify coefficients - all start at zero, have no bounds (None, None), and are
# estimated rather than fixed (0)
alpha = Beta("Intercept", 0, None, None, 0)
b_age = Beta("b_age", 0, None, None, 0)
b_college = Beta("b_college", 0, None, None, 0)
b_male = Beta("b_male", 0, None, None, 0)

# and specify the variables we want to use
age = Variable("age")
college = Variable("college")
male = Variable("gender_Male")

# specify utility functions
V = {
    # outcome 1 is WFH
    1: (alpha + b_age * age + b_college * college + b_male * male),
    # outcome 0 is non-WFH
    0: 0
}

# we also need to define the availability (more on this later)
av = {0: 1, 1: 1}

# now, set up what type of model we want (logit), what the utility functions are,
# what the availability variables are, and what the dependent variable is
logprob = models.loglogit(V, av, Variable("wfh_expectation"))

model = bio.BIOGEME(data, logprob)
model.modelName = "biogeme_binary"
model.calculate_null_loglikelihood(av)
result = model.estimate()

assert result.algorithm_has_converged()
print(result.short_summary())
print(result.get_estimated_parameters())

