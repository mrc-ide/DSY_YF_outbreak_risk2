library(YEP)
input_data=readRDS(file="exdata/input_data_DSY_2022_2050.Rds")
FOI_R0_values=readRDS(file="exdata/DSY_1000_datasets_FOI_R0.Rds")
assertthat::assert_that(all(FOI_R0_values$regions==input_data$region_labels))
regions=input_data$region_labels
n_regions=length(regions)
additional_data=readRDS(file="exdata/DSY_1000_datasets_additional.Rds")
n_param_sets=length(additional_data$vaccine_efficacy)
FOI_array=array(FOI_R0_values$FOI,dim=c(n_regions,n_param_sets))
R0_array=array(FOI_R0_values$R0,dim=c(n_regions,n_param_sets))
vaccine_efficacy=additional_data$vaccine_efficacy

years_data=c(2023)
n_years=length(years_data)
years_input_required=c(years_data[1]:(max(years_data)+1))
n_years_input_required=c(1:length(input_data$years_labels))[input_data$years_labels %in% years_input_required]

input_data_reduced=list(region_labels=input_data$region_labels,years_labels=input_data$years_labels[n_years_input_required],
                        age_labels=input_data$age_labels,vacc_data=input_data$vacc_data[,n_years_input_required,],
                        pop_data=input_data$pop_data[,n_years_input_required,])
template=list(sero_template=NULL,
              case_template=data.frame(region=sort(rep(regions,n_years)),year=rep(years_data,n_regions),
                                       cases=rep(0,n_years*n_regions)))

p_severe_inf=0.12
p_death_severe_inf=0.39
mode_start=1
start_SEIRV=NULL
dt=5.0
n_reps=10
deterministic=FALSE

case_data_multi <- Generate_Multiple_Datasets(input_data_reduced,FOI_array,R0_array,template,
                                              vaccine_efficacy, p_severe_inf, p_death_severe_inf, 
                                              p_rep_severe=rep(1.0,n_param_sets),p_rep_death=rep(1.0,n_param_sets),
                                              mode_start,start_SEIRV, dt,n_reps, deterministic = FALSE,"none",NULL)
saveRDS(list(regions=regions,cases=case_data_multi$model_case_values),file="results/case_data01.Rds")