pars = orderly_parameters(calc_id="latest")

orderly_dependency(name="case_data_calc_R0_case_seeding",
                             query=pars$calc_id,
                             c(case_data_seeded_R0_selected_datasets.Rds="case_data_seeded_R0_selected_datasets.Rds"))

orderly_artefact(description="Risk data frame", files=c("outbreak_risk (seeding+R0).csv"))

case_data=readRDS(file="case_data_seeded_R0_selected_datasets.Rds")
regions=unique(case_data$region)
n_regions=length(regions)
n_param_sets=nrow(case_data)/n_regions
cases_array=array(case_data$severe_cases,dim=c(n_regions,n_param_sets))

outbreak_risk=rep(0,n_regions)
for(n_region in 1:n_regions){
  for(n_param_set in 1:n_param_sets){
    if(cases_array[n_region,n_param_set]>=1.0){outbreak_risk[n_region]=outbreak_risk[n_region]+1}
  }
  outbreak_risk[n_region]=min(1.0,outbreak_risk[n_region]/n_param_sets)
}

output_frame=data.frame(region=regions,outbreak_risk=outbreak_risk)
write.csv(output_frame,file="outbreak_risk (seeding+R0).csv",row.names=FALSE)

