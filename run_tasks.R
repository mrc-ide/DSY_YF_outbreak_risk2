path=getwd() # Works if running from project or if working directory already set to repository folder. 
             # Otherwise set working directory to repository folder.

orderly2::orderly_init(path) #Initialize

orderly2::orderly_run("01_get_FOI_R0_values_from_saved_chain_data")

orderly2::orderly_run("02_map_FOI_R0_values")

orderly2::orderly_run("03_calc_R0_prob_values")

orderly2::orderly_run("04a_case_data_calc01_FOI_R0")

orderly2::orderly_run("04b_case_data_calc02_R0_case_seeding")

orderly2::orderly_run("05_get_outbreak_risk_from_case_data")

orderly2::orderly_run("06_outbreak_risk_seeded_weighted_by_raptor_data")

