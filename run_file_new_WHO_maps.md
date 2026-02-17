# Initialize
path=getwd() #Adjust if not using project file
library(YEPaux)
library(orderly)

# Calculate FOI/R0 values from Markov chain parameter outputs and environmental data
orderly_run("get_FOI_R0_values_from_saved_chain_data",
  list(n_param_sets=1000,enviro_filename="enviro_data_IAregions_6covs_new_labelling.csv",
  chain_filename="markov_chain_data_combined_paper_latest.Rds"))

# Create maps of FOI and R0 values
orderly_run("map_FOI_R0_values_WHO")

# Calculate case data based on seeded case and R0 values
orderly_run("case_data_calc_R0_case_seeding",
                      list(p_severe_inf=0.12, p_death_severe_inf=0.39, deterministic=FALSE,n_sets_to_run=10,n_reps=10,
                           mode_parallel=TRUE,n_cores=4))

# Calculate outbreak risk from second case data set
orderly_run("get_outbreak_risk_R0_case_seeding")

# Calculate outbreak risk based on seeding weighted by Raptor data
orderly_run("outbreak_risk_seeded_weighted_by_raptor_data",
  list(raptor_results_filename="all_DS_results_neighbours 1.rds"))
  
# Map attack rate and other alternate infection/outbreak outputs based on seeding
orderly_run("maps_create_WHO")

# Create violin plot of R0 values
orderly_run("R0_violin_plot")