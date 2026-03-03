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

#Install YEP v2.0 to make Generate_Dataset work with starting SEIRV input
# unloadNamespace("YEPaux")
# unloadNamespace("YEP")
# devtools::install_github("mrc-ide/YEP@main")

# Calculate case data based on seeded case and R0 values
orderly_run("case_data_calc_R0_case_seeding",
                      list(p_severe_inf=0.12, p_death_severe_inf=0.39,
                      deterministic=FALSE,n_sets_to_run=1000,n_reps=10,
                      mode_parallel=TRUE,n_cores=4))
#ID for 10 sets on desktop: "20260303-134428-033940ad"
#ID for 1000 sets on desktop: "20260303-134859-d3403bc2"
#ID for 1000 sets on laptop: ""

# Calculate outbreak risk from second case data set
orderly_run("get_outbreak_risk_R0_case_seeding",list(calc_id="latest"))
#ID for 10 sets on desktop: "20260303-134453-3c5717c8"
#ID for 1000 sets on desktop: "20260303-140025-e5546a3c"
#ID for 1000 sets on laptop: ""

# Calculate outbreak risk based on seeding weighted by Raptor data
orderly_run("outbreak_risk_seeded_weighted_by_raptor_data",
  list(calc_id="latest",
  raptor_results_filename="all_DS_results_neighbours 2.rds"))
  
# Map attack rate and other alternate infection/outbreak outputs based on seeding
shapefile1 = paste0(path,"/shared/shapefile_data_DSY_adm1.Rds")
shapefile2 = paste0(path,"/shared/shapefile_data_DSY_adm2.Rds")
xref_file1 = paste0(path,"/shared/xref_adm1.Rds")
xref_file2 = paste0(path,"/shared/xref_adm2.Rds")
orderly_run("maps_create_WHO",list(case_id="latest",risk_id="latest",risk_weighted_id="latest",
                                   shapefile1 = shapefile1, shapefile2 = shapefile2,
                                   xref_file1 = xref_file1, xref_file2 = xref_file2))

# Create violin plot of R0 values
orderly_run("R0_violin_plot_WHO",list(epi_id="latest", xref_file = xref_file1))

# Create plot of adm1 level starting locations?
count_file = paste0(path,"/shared/start_loc.rds")
shapefile3 = paste0(path,"/shared/shapefile_data_DSEEK_adm1.Rds")
xref_file3 = paste0(path,"/shared/xref_adm1_5countries.Rds")
orderly_run("start_loc_plot_WHO",list(count_file = count_file, xref_file = xref_file3,
                                      shapefile = shapefile3))