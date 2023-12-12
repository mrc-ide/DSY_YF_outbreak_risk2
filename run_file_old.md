# DSY_YF_outbreak_risk2
 Calculations of outbreak risk for Indian Ocean countries, run using the orderly and orderly2 packages to provide a framework for reproducibility.

 To initialize the repository, run orderly2::orderly_init(getwd()) in R after ensuring that the working directory is set to the repository folder. This will be done automatically if running from the included project file (DSY_YF_outbreak_risk2.Rproj).

 The various tasks included in the repository can be run using the orderly2::orderly_run function as shown below. They should be run in the sequence shown.

 orderly2::orderly_run("01_get_FOI_R0_values_from_saved_chain_data",list(n_param_sets=5,
  enviro_filename="enviro_data_IAregions_6covs_old_labelling_ts_error.csv",
  chain_filename="markov_chain_data_combined_paper.Rds"))

 orderly2::orderly_run("02_map_FOI_R0_values")

 orderly2::orderly_run("03_calc_R0_prob_values")

 orderly2::orderly_run("04a_case_data_calc01_FOI_R0")

 orderly2::orderly_run("04b_case_data_calc02_R0_case_seeding")

 orderly2::orderly_run("05_get_outbreak_risk_from_case_data")

 orderly2::orderly_run("06_outbreak_risk_seeded_weighted_by_raptor_data",
  list(raptor_results_filename="all_DS_results_neighboursx2.rds"))
