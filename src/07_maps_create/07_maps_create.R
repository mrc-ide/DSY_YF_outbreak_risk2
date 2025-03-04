orderly2::orderly_parameters(case_id="latest",risk_id="latest")

orderly2::orderly_dependency(name="04b_case_data_calc02_R0_case_seeding",
                            query=case_id,
                            c("case_data_seeded_R0_selected_datasets.Rds"="case_data_seeded_R0_selected_datasets.Rds"))
orderly2::orderly_dependency(name="05b_get_outbreak_risk02_R0_case_seeding",
                             query=risk_id,
                             c("outbreak_risk (seeding+R0).csv"="outbreak_risk (seeding+R0).csv"))

orderly2::orderly_shared_resource('shapefiles/DJI/gadm36_DJI_1.cpg' = 'shapefiles/DJI/gadm36_DJI_1.cpg', 
                                  'shapefiles/DJI/gadm36_DJI_1.dbf' = 'shapefiles/DJI/gadm36_DJI_1.dbf', 
                                  'shapefiles/DJI/gadm36_DJI_1.prj' = 'shapefiles/DJI/gadm36_DJI_1.prj', 
                                  'shapefiles/DJI/gadm36_DJI_1.shp' = 'shapefiles/DJI/gadm36_DJI_1.shp', 
                                  'shapefiles/DJI/gadm36_DJI_1.shx' = 'shapefiles/DJI/gadm36_DJI_1.shx', 
                                  'shapefiles/SOM/gadm36_SOM_1.cpg' = 'shapefiles/SOM/gadm36_SOM_1.cpg', 
                                  'shapefiles/SOM/gadm36_SOM_1.dbf' = 'shapefiles/SOM/gadm36_SOM_1.dbf', 
                                  'shapefiles/SOM/gadm36_SOM_1.prj' = 'shapefiles/SOM/gadm36_SOM_1.prj',
                                  'shapefiles/SOM/gadm36_SOM_1.shp' = 'shapefiles/SOM/gadm36_SOM_1.shp', 
                                  'shapefiles/SOM/gadm36_SOM_1.shx' = 'shapefiles/SOM/gadm36_SOM_1.shx', 
                                  'shapefiles/YEM/gadm36_YEM_1.cpg' = 'shapefiles/YEM/gadm36_YEM_1.cpg', 
                                  'shapefiles/YEM/gadm36_YEM_1.dbf' = 'shapefiles/YEM/gadm36_YEM_1.dbf', 
                                  'shapefiles/YEM/gadm36_YEM_1.prj' = 'shapefiles/YEM/gadm36_YEM_1.prj', 
                                  'shapefiles/YEM/gadm36_YEM_1.shp' = 'shapefiles/YEM/gadm36_YEM_1.shp', 
                                  'shapefiles/YEM/gadm36_YEM_1.shx' = 'shapefiles/YEM/gadm36_YEM_1.shx')

orderly2::orderly_artefact(description="Mean attack rate map", files=c("outbreak risk map (seeding+R0).png",
                                                                       "mean attack rate (all) map (seeding+R0).png",
                                                                       "mean attack rate (outbreaks) map (seeding+R0).png",
                                                                       "mean secondary infections (all) map (seeding+R0).png",
                                                                       "mean secondary infections (outbreaks) map (seeding+R0).png",
                                                                       "mean outbreak size map (seeding+R0).png"))

case_data=readRDS(file="case_data_seeded_R0_selected_datasets.Rds")
# if(is.null(case_data$severe_cases)){ #TEMP
#   case_data$severe_cases=case_data$cases
#   case_data$cases=round(case_data$cases/0.12)
# }
regions=unique(case_data$region)
n_regions=length(regions)
n_param_sets=nrow(case_data)/n_regions

attack_rate_mean1=rowMeans(array(case_data$attack_rates,dim=c(n_regions,n_param_sets)))
outbreak_size_mean1=rowMeans(array(case_data$severe_cases,dim=c(n_regions,n_param_sets)))
secondary_infs_mean1=rowMeans(array(case_data$cases-1,dim=c(n_regions,n_param_sets)))
attack_rate_mean2=secondary_infs_mean2=outbreak_size_mean2=rep(NA,n_regions)
for(n_region in 1:n_regions){
  subset=subset(case_data,region==regions[n_region])
  pts=subset$cases>=1.0
  attack_rate_mean2[n_region]=mean(subset$attack_rates[pts])
  outbreak_size_mean2[n_region]=mean(subset$severe_cases[pts])
  secondary_infs_mean2[n_region]=mean(subset$cases[pts]-1)
}
attack_rate_mean2[is.na(attack_rate_mean2)]=0.0
secondary_infs_mean2[is.na(secondary_infs_mean2)]=0.0
outbreak_size_mean2[is.na(outbreak_size_mean2)]=0.0

country_list=unique(substr(regions,1,3))
shapefiles=rep("",length(country_list))
for(i in 1:length(country_list)){
  shapefiles[i]=paste("shapefiles/",country_list[i],"/gadm36_",country_list[i],"_1.shp",sep="")
}
shape_data=map_shapes_load(regions, shapefiles, region_label_type="GID_1")
# colour_scheme=readRDS(file=paste(path.package("YEPaux"), "exdata/colour_scheme_example.Rds", sep="/"))
# colour_scale=colour_scheme$colour_scale
palette=MetBrewer::met.brewer("Hiroshige")
colour_scale=as.vector(palette)[c(10:1)]

outbreak_risk_data=read.csv(file="outbreak_risk (seeding+R0).csv",header=TRUE)

scale_risk=c(0,0.01,0.05,0.1,0.25,0.5,0.75,0.9,0.95,0.99,1.0)
png("outbreak risk map (seeding+R0).png",width=945.507,height=1440)
create_map(shape_data,outbreak_risk_data$outbreak_risk,scale=scale_risk,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="Outbreak probability",legend_position="bottomright",
           legend_format="f",legend_dp=2,output_file=NULL)
dev.off()

scale_ar=c(0,1e-6,2.5e-6,5e-6,7.5e-6,1e-5,2.5e-5,5e-5,7.5e-5,1e-4,2.5e-4)
png("mean attack rate (all) map (seeding+R0).png",width=945.507,height=1440)
create_map(shape_data,attack_rate_mean1,scale=scale_ar,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="Mean attack rate (all)",legend_position="bottomright",
           legend_format="e",legend_dp=1,output_file=NULL)
dev.off()
png("mean attack rate (outbreaks) map (seeding+R0).png",width=945.507,height=1440)
create_map(shape_data,attack_rate_mean2,scale=scale_ar,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="Mean attack rate (outbreaks)",legend_position="bottomright",
           legend_format="e",legend_dp=1,output_file=NULL)
dev.off()

scale_si=c(0,1,2,2.5,3,4,5,10,25,50,100)
png("mean secondary infections (all) map (seeding+R0).png",width=945.507,height=1440)
create_map(shape_data,secondary_infs_mean1,scale=scale_si,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="Mean secondary infections (all)",legend_position="bottomright",
           legend_format="e",legend_dp=1,output_file=NULL)
dev.off()

png("mean secondary infections (outbreaks) map (seeding+R0).png",width=945.507,height=1440)
create_map(shape_data,secondary_infs_mean2,scale=scale_si,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="Mean secondary infections (outbreaks)",legend_position="bottomright",
           legend_format="e",legend_dp=1,output_file=NULL)
dev.off()

scale_os=c(0,1,1.25,1.5,1.75,2,2.5,5,7.5,10,12.5)
png("mean outbreak size map (seeding+R0).png",width=945.507,height=1440)
create_map(shape_data,outbreak_size_mean2,scale=scale_os,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="Mean outbreak size",legend_position="bottomright",
           legend_format="e",legend_dp=1,output_file=NULL)
dev.off()
