#TODO - finalize legend size/position and scale values (based on larger number of sets)

library(YEPaux)

pars = orderly2::orderly_parameters(case_id="latest",risk_id="latest")

orderly2::orderly_dependency(name="case_data_calc_R0_case_seeding",
                            query=pars$case_id,
                            c("case_data_seeded_R0_selected_datasets.Rds"="case_data_seeded_R0_selected_datasets.Rds"))
orderly2::orderly_dependency(name="get_outbreak_risk_R0_case_seeding",
                             query=pars$risk_id,
                             c("outbreak_risk (seeding+R0).csv"="outbreak_risk (seeding+R0).csv"))

#Load new shape data and region cross-referencing table
orderly2::orderly_shared_resource('shapefile_data_DSY_adm1.Rds' = 'shapefile_data_DSY_adm1.Rds',
                                  'xref_adm1.Rds' = 'xref_adm1.Rds')

orderly2::orderly_artefact(description="Mean attack rate map", files=c("outbreak risk map (seeding+R0).png",
                                                                       "mean attack rate (all) map (seeding+R0).png",
                                                                       "mean attack rate (outbreaks) map (seeding+R0).png",
                                                                       "mean secondary infections (all) map (seeding+R0).png",
                                                                       "mean secondary infections (outbreaks) map (seeding+R0).png",
                                                                       "mean outbreak size map (seeding+R0).png"))

#Load case data based on GADM regions
case_data=readRDS(file="case_data_seeded_R0_selected_datasets.Rds")
regions_gadm=unique(case_data$region)
n_regions_gadm=length(regions_gadm)
n_param_sets=nrow(case_data)/n_regions_gadm

#Load WHO shapefile data and conversion table
shape_data=readRDS("shapefile_data_DSY_adm1.Rds")
xref_table=readRDS("xref_adm1.Rds")
regions_who=shape_data$region
#Create index to remap FOI/R0 values onto WHO regions
xref_index=rep(NA,length(regions_who))
for(i in 1:length(regions_who)){
  index1=which(xref_table$WHO_Name==regions_who[i])
  xref_index[i]=which(regions_gadm==xref_table$GADM_ID[index1])
}

#Calculate outputs for GADM regions
attack_rate_mean1=rowMeans(array(case_data$attack_rates,dim=c(n_regions_gadm,n_param_sets)))
outbreak_size_mean1=rowMeans(array(case_data$severe_cases,dim=c(n_regions_gadm,n_param_sets)))
secondary_infs_mean1=rowMeans(array(case_data$cases-1,dim=c(n_regions_gadm,n_param_sets)))
attack_rate_mean2=secondary_infs_mean2=outbreak_size_mean2=rep(NA,n_regions_gadm)
for(n_region in 1:n_regions_gadm){
  subset=subset(case_data,region==regions[n_region])
  pts=subset$severe_cases>=1.0
  attack_rate_mean2[n_region]=mean(subset$attack_rates[pts])
  outbreak_size_mean2[n_region]=mean(subset$severe_cases[pts])
  secondary_infs_mean2[n_region]=mean(subset$cases[pts]-1)
}
attack_rate_mean2[is.na(attack_rate_mean2)]=0.0
secondary_infs_mean2[is.na(secondary_infs_mean2)]=0.0
outbreak_size_mean2[is.na(outbreak_size_mean2)]=0.0
outbreak_risk_data=read.csv(file="outbreak_risk (seeding+R0).csv",header=TRUE)

#Map outputs onto WHO regions
outbreak_risk_who=outbreak_risk_data$outbreak_risk[xref_index]
attack_rate_mean1_who=attack_rate_mean1[xref_index]
attack_rate_mean2_who=attack_rate_mean2[xref_index]
secondary_infs_mean1_who=secondary_infs_mean1[xref_index]
secondary_infs_mean2_who=secondary_infs_mean2[xref_index]
outbreak_size_mean2_who=outbreak_size_mean2[xref_index]

palette=MetBrewer::met.brewer("Hiroshige")
colour_scale=as.vector(palette)[c(10:1)]

scale_risk=c(0,0.01,0.05,0.1,0.25,0.5,0.75,0.9,0.95,1.0)
map1=create_map(shape_data=shape_data,param_values=outbreak_risk_who,text_size=5,
                   display_axes=FALSE,border_colour_regions = "grey",
                   scale_manual=scale_risk,colour_scale_manual=colour_scale,
                   pixels_max=1440,map_title=NULL,legend_title="Outbreak probability",
                   legend_position=c(0.8,0.3),legend_format="f",legend_dp=2)
map1 <- map1+ theme(legend.key.size = unit(0.25, "cm"))
ggsave(filename="outbreak risk map (seeding+R0).png",plot=map1,
       width=945.507,height=1440,units="px",bg="white")

scale_ar=c(0,2.5e-6,5e-6,7.5e-6,1e-5,2.5e-5,5e-5,7.5e-5,1e-4,2.5e-4) #TODO - adjust
map2=create_map(shape_data=shape_data,param_values=attack_rate_mean1_who,text_size=5,
                display_axes=FALSE,border_colour_regions = "grey",
                scale_manual=scale_ar,colour_scale_manual=colour_scale,
                pixels_max=1440,map_title=NULL,legend_title="Mean attack rate (all)",
                legend_position=c(0.8,0.3),legend_format="e",legend_dp=2)
map2 <- map2+ theme(legend.key.size = unit(0.25, "cm"))
ggsave(filename="mean attack rate (all) map (seeding+R0).png",plot=map2,
       width=945.507,height=1440,units="px",bg="white")

#png("mean attack rate (outbreaks) map (seeding+R0).png",width=945.507,height=1440)
map3=create_map(shape_data=shape_data,param_values=attack_rate_mean2_who,text_size=5,
                display_axes=FALSE,border_colour_regions = "grey",
                scale_manual=scale_ar,colour_scale_manual=colour_scale,
                pixels_max=1440,map_title=NULL,legend_title="Mean attack rate (outbreaks)",
                legend_position=c(0.8,0.3),legend_format="e",legend_dp=1)
map3 <- map3+ theme(legend.key.size = unit(0.25, "cm"))
ggsave(filename="mean attack rate (outbreaks) map (seeding+R0).png",plot=map3,
       width=945.507,height=1440,units="px",bg="white")

scale_si=c(0,1,2,3,4,5,10,25,50,100)
map4=create_map(shape_data=shape_data,param_values=secondary_infs_mean1_who,text_size=5,
                display_axes=FALSE,border_colour_regions = "grey",
                scale_manual=scale_si,colour_scale_manual=colour_scale,
                pixels_max=1440,map_title=NULL,legend_title="Mean secondary infections (all)",
                legend_position=c(0.8,0.3),legend_format="f",legend_dp=2)
map4 <- map4+ theme(legend.key.size = unit(0.25, "cm"))
ggsave(filename="mean secondary infections (all) map (seeding+R0).png",plot=map4,
       width=945.507,height=1440,units="px",bg="white")

map5=create_map(shape_data=shape_data,param_values=secondary_infs_mean2_who,text_size=5,
                display_axes=FALSE,border_colour_regions = "grey",
                scale_manual=scale_si,colour_scale_manual=colour_scale,
                pixels_max=1440,map_title=NULL,legend_title="Mean secondary infections (outbreaks)",
                legend_position=c(0.8,0.3),legend_format="f",legend_dp=2)
map5 <- map5+ theme(legend.key.size = unit(0.25, "cm"))
ggsave(filename="mean secondary infections (outbreaks) map (seeding+R0).png",plot=map5,
       width=945.507,height=1440,units="px",bg="white")

scale_os=c(0,1,1.5,1.75,2,2.5,5,7.5,10,12.5)
map6=create_map(shape_data=shape_data,param_values=outbreak_size_mean2_who,text_size=5,
                display_axes=FALSE,border_colour_regions = "grey",
                scale_manual=scale_os,colour_scale_manual=colour_scale,
                pixels_max=1440,map_title=NULL,legend_title="Mean outbreak size",
                legend_position=c(0.8,0.3),legend_format="f",legend_dp=2)
map6 <- map6+ theme(legend.key.size = unit(0.25, "cm"))
ggsave(filename="mean outbreak size map (seeding+R0).png",plot=map6,
       width=945.507,height=1440,units="px",bg="white")

