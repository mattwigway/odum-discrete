using DataFrames, CSV, DataFramesMeta

data = CSV.read("data/covidfuture_wave_3_public_Main_3.0.0b6.csv", DataFrame)
w1_data = CSV.read("data/covid_pooled_public_w1b_1.1.0b7.csv", DataFrame)
wfh_data = @chain data begin
    @subset(:w3_empl_now .∈ Ref(["Yes, working full-time", "Yes, working part-time or reduced hours"]) .&&
        :w3_wfh_policy_expect .≠ "Question not displayed to respondent")
    leftjoin(w1_data, on=:resp_id)
    @transform(:wfh_expectation = :w3_wfh_policy_expect .∈ Ref([
        "I expect to be able to choose to work from home, but only on some days",
        "I expect to be able to choose to work from home as much as I want",
        "I expect to have to work from home whenever I am working"
    ]))
    @select(:wfh_expectation, :age, :gender, :college = :educ .∈ Ref([
         "Bachelor's degree(s) or some graduate school",
        "Completed graduate degree(s)"
    ]),
        :black = :race_2 .== "Black/African American",
        :hispanic = :hispanic .== "Yes"
    )
end

CSV.write("data/wfh_prediction_covidfuture.csv", wfh_data)


