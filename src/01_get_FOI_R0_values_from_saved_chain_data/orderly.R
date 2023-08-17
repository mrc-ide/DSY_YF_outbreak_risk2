library(YEPaux)

enviro_data=read.csv(file="exdata/enviro_data_IAregions_6covs_old_labelling_ts_error.csv",header=TRUE)
regions=enviro_data$region
n_regions=length(regions)
n_env_vars=ncol(enviro_data)-1
env_vars=colnames(enviro_data)[1+c(1:n_env_vars)]

chain_data=readRDS(file="exdata/markov_chain_data_combined_paper.Rds")

n_param_sets=1000
n_entries=nrow(chain_data)
interval=floor(n_entries/n_param_sets)
lines=c(1:n_param_sets)*interval
chain_data_selected=chain_data[lines,c(2:ncol(chain_data))]
FOI_R0_values=get_mcmc_FOI_R0_data(chain_data_selected,type="FOI+R0 enviro",enviro_data)

FOI_values_array=array(data=FOI_R0_values$FOI,dim=c(n_regions,n_param_sets))
R0_values_array=array(data=FOI_R0_values$R0,dim=c(n_regions,n_param_sets))

saveRDS(FOI_R0_values,file="exdata/DSY_1000_datasets_FOI_R0.Rds")
saveRDS(list(regions=regions,p_rep_severe=chain_data_selected$p_rep_severe,vaccine_efficacy=chain_data_selected$vaccine_efficacy,
             p_rep_death=chain_data_selected$p_rep_death),file="exdata/DSY_1000_datasets_additional.Rds")