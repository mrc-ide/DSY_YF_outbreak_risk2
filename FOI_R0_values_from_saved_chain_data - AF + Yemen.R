#comp="C:/Users/Work_KJF82"
comp="C:/Users/kjfras16"
library(YEPaux)
#devtools::load_all(path=paste(comp,"Documents/Git repositories/YEP",sep="/"))

{
  dir1a="Documents/0 - Yellow fever model MCMC results/Model runs 2022-10"
  dir1b="Run2022_10_C_case_sero_272regions_newCFR"
  dir2="Documents/0 - R files/YEP + YFD - Indian Ocean countries new calculations"
  dir3="Documents/00 - Big data files to back up infrequently/00 - YellowFeverDynamics key datasets"

  enviro_data_DSY=read.csv(file=paste(comp,dir2,"exdata/enviro_data_IAregions_6covs_old_labelling_ts_error.csv",sep="/"),header=TRUE)
  enviro_data_YEM=subset(enviro_data_DSY,substr(region,1,3)=="YEM")

  enviro_data_af_sa=read.csv(file=paste(comp,dir3,"enviro_data_all2.csv",sep="/"),header=TRUE)
  colnames(enviro_data_af_sa)[colnames(enviro_data_af_sa)=="temp_suit_mean"]="temp_suit_mean_actual"
  colnames(enviro_data_af_sa)[colnames(enviro_data_af_sa)=="temp_mean"]="temp_suit_mean"
  enviro_data_af_sa=enviro_data_af_sa[,colnames(enviro_data_af_sa) %in% colnames(enviro_data_YEM)]
  #regions_input_data=readRDS(paste(comp,dir3,"input_data_af.Rds",sep="/"))

  enviro_data_af_sa_YEM=rbind(enviro_data_af_sa,enviro_data_YEM)

  FOI_R0_data_af_yem_old=read.csv(file=paste(comp,dir2,"exdata/FOI_R0_med_values_af_yem_old.csv",sep="/"),header=TRUE)
  regions=FOI_R0_data_af_yem_old$regions
  enviro_data_af_YEM=subset(enviro_data_af_sa_YEM,region %in% regions)
  enviro_data_af_YEM$MIR.max=as.numeric(enviro_data_af_YEM$MIR.max)
  enviro_data_af_YEM=enviro_data_af_YEM[order(enviro_data_af_YEM$region),]

  n_regions=length(regions)
  assertthat::assert_that(all(regions==enviro_data_af_YEM$region))
  n_env_vars=ncol(enviro_data_af_YEM)-1
  env_vars=colnames(enviro_data_af_YEM)[1+c(1:n_env_vars)]
}

chain_data_combined=readRDS(file=paste(comp,dir1a,dir1b,"chain_data_combined.Rds",sep="/"))
# n_lines=nrow(chain_data_combined)
# n_sets=1000
# interval=floor((n_lines-1)/n_sets)
# lines_selected=c(1:n_sets)*interval
# chain_data_selected=chain_data_combined[lines_selected,c(2:ncol(chain_data_combined))]
# write.csv(chain_data_selected,file=paste(comp,dir2,"exdata/chain_data_1000.csv",sep="/"),row.names=FALSE)

#Re-ordering environmental data
enviro_data2=enviro_data_af_YEM
enviro_cols_chain_order=c("region","logpop","temp_suit_mean","LC10","aegypti","MIR.max","monkeys_combined")
enviro_data2=enviro_data_af_YEM[,match(enviro_cols_chain_order,colnames(enviro_data_af_YEM))]
env_vars2=colnames(enviro_data2)[1+c(1:n_env_vars)]

assertthat::assert_that(all(colnames(chain_data_combined)[1+c(1:n_env_vars)]==paste("FOI_",env_vars2,sep="")),msg="")
assertthat::assert_that(all(colnames(chain_data_combined)[1+n_env_vars+c(1:n_env_vars)]==paste("R0_",env_vars2,sep="")),msg="")
n_entries=nrow(chain_data_combined)
FOI_R0_values=get_mcmc_FOI_R0_data(chain_data_combined,type="FOI+R0 enviro",enviro_data2)

blank=rep(NA,n_regions)
FOI_R0_summary=data.frame(region=regions,FOI_025=blank,FOI_25=blank,FOI_50=blank,FOI_75=blank,FOI_975=blank,FOI_mean=blank,
                          R0_025=blank,R0_25=blank,R0_50=blank,R0_75=blank,R0_975=blank,R0_mean=blank)
n_025=ceiling(n_entries*0.025)
n_25=ceiling(n_entries*0.25)
n_75=floor(n_entries*0.75)
n_975=floor(n_entries*0.975)
for(i in 1:n_regions){
  lines=i+(n_regions*c(0:(n_entries-1)))
  FOI_values=sort(FOI_R0_values$FOI[lines])
  R0_values=sort(FOI_R0_values$R0[lines])
  FOI_R0_summary$FOI_025[i]=FOI_values[n_025]
  FOI_R0_summary$FOI_25[i]=FOI_values[n_25]
  FOI_R0_summary$FOI_50[i]=median(FOI_values)
  FOI_R0_summary$FOI_75[i]=FOI_values[n_75]
  FOI_R0_summary$FOI_975[i]=FOI_values[n_975]
  FOI_R0_summary$FOI_mean[i]=mean(FOI_values)
  FOI_R0_summary$R0_025[i]=R0_values[n_025]
  FOI_R0_summary$R0_25[i]=R0_values[n_25]
  FOI_R0_summary$R0_50[i]=median(R0_values)
  FOI_R0_summary$R0_75[i]=R0_values[n_75]
  FOI_R0_summary$R0_975[i]=R0_values[n_975]
  FOI_R0_summary$R0_mean[i]=mean(R0_values)
}
write.csv(FOI_R0_summary,file=paste(comp,dir2,"exdata/FOI_R0_med_values_af_yem_new.csv",sep="/"),row.names=FALSE)
