# Initialize
path=getwd() #Adjust if not using project file
orderly2::orderly_init(path)

# Calculate FOI/R0 values from Markov chain parameter outputs and environmental data
orderly2::orderly_run("01_get_FOI_R0_values_from_saved_chain_data",
  list(
  n_param_sets=1000,
  enviro_filename="enviro_data_IAregions_6covs_new_labelling.csv",
  chain_filename="markov_chain_data_combined_paper_latest.Rds"))

# Create maps of FOI and R0 values
orderly2::orderly_run("02_map_FOI_R0_values")

# Create maps of probabilities that R0 equals or exceeds certain values
orderly2::orderly_run("03_calc_R0_prob_values")

# Calculate
orderly2::orderly_run("04a_case_data_calc01_FOI_R0")

# Calculate
orderly2::orderly_run("04b_case_data_calc02_R0_case_seeding")

# Calculate
orderly2::orderly_run("05_get_outbreak_risk_from_case_data")

# Calculate
orderly2::orderly_run("06_outbreak_risk_seeded_weighted_by_raptor_data",
  list(raptor_results_filename="all_DS_results_neighboursx2.rds"))
