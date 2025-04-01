orderly2::orderly_parameters(p_severe_inf=0.12, p_death_severe_inf=0.39, deterministic=FALSE, n_sets_to_run=NULL, n_reps=1,
                             mode_parallel=FALSE, n_cores=1)

orderly2::orderly_dependency(name="01_get_FOI_R0_values_from_saved_chain_data", 
                             query="latest",
                             files=c(DSY_selected_datasets_FOI_R0.Rds="DSY_selected_datasets_FOI_R0.Rds",
                                     DSY_selected_datasets_additional.Rds="DSY_selected_datasets_additional.Rds"))

orderly2::orderly_shared_resource("input_data.Rds"="input_data.Rds")

orderly2::orderly_artefact(description="All data", files=c("case_data_seeded_R0_selected_datasets.Rds"))

library(YEP)
input_data=readRDS(file="input_data.Rds")
FOI_R0_values=readRDS(file="DSY_selected_datasets_FOI_R0.Rds")
assertthat::assert_that(all(FOI_R0_values$regions==input_data$region_labels))
regions=input_data$region_labels
n_regions=length(regions)
additional_data=readRDS(file="DSY_selected_datasets_additional.Rds")
n_param_sets=length(additional_data$vaccine_efficacy)
if(deterministic){assertthat::assert_that(n_reps==1)}
if(is.null(n_sets_to_run)){
  selection=c(1:n_param_sets)
}else{
  assertthat::assert_that(n_sets_to_run<=n_param_sets)
  if(n_sets_to_run<n_param_sets){
    interval=floor(n_param_sets/n_sets_to_run)
    selection=ceiling(interval/2)+(interval*c(0:(n_sets_to_run-1)))
  } else {
    selection=c(1:n_param_sets)
  }
}

years_data=c(2023)
n_years=length(years_data)
years_input_required=c(years_data[1]:(max(years_data)+1))
n_years_input_required=c(1:length(input_data$years_labels))[input_data$years_labels %in% years_input_required]

input_data_reduced=list(region_labels=input_data$region_labels,years_labels=input_data$years_labels[n_years_input_required],
                        age_labels=input_data$age_labels,vacc_data=input_data$vacc_data[,n_years_input_required,],
                        pop_data=input_data$pop_data[,n_years_input_required,])
case_template=data.frame(region=sort(rep(regions,n_years)),year=rep(years_data,n_regions),cases=rep(0,n_years*n_regions))

mode_start=2
start_SEIRV=list()
for(n_region in 1:n_regions){
  P0=input_data_reduced$pop_data[n_region,1,]
  start_SEIRV[[n_region]]=list(S=P0,E=P0*0,I=P0*0,R=P0*0,V=P0*0)
  start_SEIRV[[n_region]]$E[21]=1 #Seed single infected 21-year-old in each region
  start_SEIRV[[n_region]]$S[21]=start_SEIRV[[n_region]]$S[21]-1
}
time_inc=5.0

if(mode_parallel){cluster=parallel::makeCluster(n_cores)}else{cluster=NULL}
for(set in selection){
  if(set %% 10 == 1){cat("\n")}
  cat(set,"\t")
  dataset_single <- Generate_Dataset(FOI_values = array(0,dim=c(n_regions,1)),
                                     R0_values = array(FOI_R0_values$R0[set,,],dim=c(n_regions,1)),
                                     input_data_reduced,sero_template = NULL,case_template = case_template,
                                     vaccine_efficacy = additional_data$vaccine_efficacy[set], time_inc = time_inc, mode_start = mode_start, 
                                     start_SEIRV = start_SEIRV, mode_time = 0,n_reps = n_reps,deterministic = deterministic, 
                                     p_severe_inf = p_severe_inf, p_death_severe_inf = p_death_severe_inf,
                                     p_rep_severe = 1.0,p_rep_death = 1.0,mode_parallel = mode_parallel,cluster = cluster,
                                     output_frame = TRUE, seed = set)
  if(set==selection[1]){
    datasets_all=dataset_single$model_case_data[,c(1,3)]
  } else {
    datasets_all=rbind(datasets_all,dataset_single$model_case_data[,c(1,3)])
  }
}
if(mode_parallel){parallel::stopCluster(cluster)}
datasets_all$severe_cases=datasets_all$cases
datasets_all$cases=datasets_all$severe_cases/p_severe_inf
datasets_all$attack_rates=datasets_all$cases/rowSums(input_data_reduced$pop_data[,1,])

saveRDS(datasets_all,file="case_data_seeded_R0_selected_datasets.Rds")