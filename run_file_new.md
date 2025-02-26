# Initialize
path=getwd() #Adjust if not using project file
orderly2::orderly_init(path)
library(YEPaux)

# Calculate FOI/R0 values from Markov chain parameter outputs and environmental data
orderly2::orderly_run("01_get_FOI_R0_values_from_saved_chain_data",
  list(n_param_sets=1000,enviro_filename="enviro_data_IAregions_6covs_new_labelling.csv",
  chain_filename="markov_chain_data_combined_paper_latest.Rds"))

# Create maps of FOI and R0 values
orderly2::orderly_run("02_map_FOI_R0_values")

# Create maps of probabilities that R0 equals or exceeds certain values
#orderly2::orderly_run("03_calc_R0_prob_values") #TBC

# Calculate case data based on FOI/R0 values
#orderly2::orderly_run("04a_case_data_calc01_FOI_R0",list(p_severe_inf=0.12, p_death_severe_inf=0.39)) #TBC

# Calculate case data based on seeded case and R0 values
orderly2::orderly_run("04b_case_data_calc02_R0_case_seeding",list(p_severe_inf=0.12, p_death_severe_inf=0.39)) #TBC

# Calculate outbreak risk from first case data set
#orderly2::orderly_run("05a_get_outbreak_risk01_FOI_R0")

# Calculate outbreak risk from second case data set
orderly2::orderly_run("05b_get_outbreak_risk02_R0_case_seeding")

# Calculate outbreak risk based on seeding weighted by Raptor data
orderly2::orderly_run("06_outbreak_risk_seeded_weighted_by_raptor_data",
  list(raptor_results_filename="all_DS_results_neighbours 1.rds"))
  
# Calculate outbreak risk based on seeding weighted by Raptor data - alternate map
orderly2::orderly_run("07_weighted_outbreak_risk_alt_map",
  list(raptor_results_filename="all_DS_results_neighbours 1.rds"))
  
# Calculate attack rate based on seeding
orderly2::orderly_run("08_get_attack_rate")