#Run seeded case data calculation to examine sensitivity to R0 parameter

pars <- orderly2::orderly_parameters(p_severe_inf=0.12, p_death_severe_inf=0.39, n_sets_to_run=NULL, 
                                     n_reps=1, mode_parallel=FALSE, n_cores=1)

orderly2::orderly_dependency(name="get_FOI_R0_values_from_saved_chain_data", 
                             query="latest",
                             files=c(DSY_selected_datasets_FOI_R0.Rds="DSY_selected_datasets_FOI_R0.Rds",
                                     DSY_selected_datasets_additional.Rds="DSY_selected_datasets_additional.Rds"))

orderly2::orderly_shared_resource("input_data.Rds"="input_data.Rds")

orderly2::orderly_artefact(description="All data", files=c("data_all.Rds"))

library(YEP)
input_data=readRDS(file="input_data.Rds")
FOI_R0_values=readRDS(file="DSY_selected_datasets_FOI_R0.Rds")
assertthat::assert_that(all(FOI_R0_values$regions==input_data$region_labels))
regions=input_data$region_labels
n_regions=length(regions)
additional_data=readRDS(file="DSY_selected_datasets_additional.Rds")
n_param_sets=length(additional_data$vaccine_efficacy)
if(is.null(pars$n_sets_to_run)){
  selection=c(1:n_param_sets)
}else{
  assertthat::assert_that(pars$n_sets_to_run<=n_param_sets)
  if(pars$n_sets_to_run<n_param_sets){
    interval=floor(n_param_sets/pars$n_sets_to_run)
    selection=ceiling(interval/2)+(interval*c(0:(pars$n_sets_to_run-1)))
  } else {
    selection=c(1:n_param_sets)
  }
}

years_data=c(2023)
n_years=length(years_data)
years_input_required=c(years_data[1]:(max(years_data)+1))
n_years_input_required=c(1:length(input_data$years_labels))[input_data$years_labels %in% years_input_required]

input_data_reduced=list(region_labels=input_data$region_labels,
                        years_labels=input_data$years_labels[n_years_input_required],
                        age_labels=input_data$age_labels,vacc_data=input_data$vacc_data[,n_years_input_required,],
                        pop_data=input_data$pop_data[,n_years_input_required,])
case_template=data.frame(region=sort(rep(regions,n_years)),year=rep(years_data,n_regions),
                         cases=rep(0,n_years*n_regions))

mode_start=2
start_SEIRV=list()
for(n_region in 1:n_regions){
  P0=input_data_reduced$pop_data[n_region,1,]
  start_SEIRV[[n_region]]=list(S=P0,E=P0*0,I=P0*0,R=P0*0,V=P0*0)
  start_SEIRV[[n_region]]$E[21]=1 #Seed single infected 21-year-old in each region
  start_SEIRV[[n_region]]$S[21]=start_SEIRV[[n_region]]$S[21]-1
}
time_inc=5.0

case_array=array(NA,dim=c(n_regions,length(selection),pars$n_reps))
if(pars$mode_parallel){cluster=parallel::makeCluster(pars$n_cores)}else{cluster=NULL}
for(set in selection){
  n_set = match(set,selection)
  if(set %% 10 == 1){cat("\n")}
  cat(set,"\t")
  for(n_rep in 1:n_reps){
    dataset_single <- Generate_Dataset(FOI_values = array(0,dim=c(n_regions,1)),
                                       R0_values = array(FOI_R0_values$R0[set,,],dim=c(n_regions,1)),
                                       input_data_reduced,sero_template = NULL,case_template = case_template,
                                       vaccine_efficacy = additional_data$vaccine_efficacy[set], 
                                       time_inc = time_inc, mode_start = mode_start, 
                                       start_SEIRV = start_SEIRV, mode_time = 0,n_reps = 1, deterministic = FALSE, 
                                       p_severe_inf = pars$p_severe_inf, 
                                       p_death_severe_inf = pars$p_death_severe_inf,
                                       p_rep_severe = 1.0,p_rep_death = 1.0,
                                       mode_parallel = pars$mode_parallel,cluster = cluster, 
                                       output_frame = FALSE, seed = set)
    case_array[,n_set,n_rep]=dataset_single$model_case_values
  }
}
if(pars$mode_parallel){parallel::stopCluster(cluster)}

saveRDS(case_array,"data_all.Rds")

R0_sens_data = list(R0_values = t(FOI_R0_values$R0[selection,,1]),
                    risk_values = array(NA,dim=c(n_regions,n_sets_to_run)))
for(n_set in 1:n_sets_to_run){
  for(n_region in 1:n_regions){
    case_values=case_array[n_region,n_set,] 
    R0_sens_data$risk_values[n_region,n_set]=length(case_values[case_values>0])
  }
}
R0_sens_data$risk_values=R0_sens_data$risk_values/n_reps

saveRDS(R0_sens_data,"R0_sens_data.Rds")

regions_select=c(1:n_regions)[matrixStats::rowMaxs(R0_sens_data$R0_values)>0.9]
xlim=c(min(R0_sens_data$R0_values[regions_select]),max(R0_sens_data$R0_values[regions_select]))
matplot(x=xlim,y=c(0,1),type="p",col=0,xlim=xlim,ylim=c(0,1),xlab="R0",ylab="Risk")
for(n_region in regions_select){
  matplot(x=R0_sens_data$R0_values[n_region,order(R0_sens_data$R0_values[n_region,])],
          y=R0_sens_data$risk_values[n_region,order(R0_sens_data$R0_values[n_region,])],
          type="l",pch=1,col="grey",add=TRUE)
}