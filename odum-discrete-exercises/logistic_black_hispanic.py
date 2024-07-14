import pandas as pd, statsmodels.api as sm

data = pd.read_csv("data/wfh_prediction_covidfuture.csv")

model = sm.Logit(
    data.wfh_expectation, # dependent variables
    sm.add_constant( # add an intercept to the dataframe
        pd.get_dummies( # convert gender to a dummy variable
            data[["age", "gender", "college", "black", "hispanic"]],
        )
        .drop(columns=["gender_Female"]) # drop one category from dummy variable
        .astype("float64") # convert everything to numeric
    )
)

result = model.fit()
print(result.summary())

