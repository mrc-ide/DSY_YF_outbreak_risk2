orderly2::orderly_parameters(case_id="latest")

orderly2::orderly_dependency(name="04b_case_data_calc02_R0_case_seeding",
                            query=case_id,
                            c("case_data_seeded_R0_selected_datasets.Rds"="case_data_seeded_R0_selected_datasets.Rds"))

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

orderly2::orderly_artefact(description="Mean attack rate map", files=c("mean attack rate (all) map (seeding+R0).png",
                                                                       "mean attack rate (modified) map (seeding+R0).png"))

case_data=readRDS(file="case_data_seeded_R0_selected_datasets.Rds")
regions=unique(case_data$region)
n_regions=length(regions)
n_param_sets=nrow(case_data)/n_regions
attack_rate_array=array(case_data$attack_rates,dim=c(n_regions,n_param_sets))
attack_rate_mean1=rowMeans(attack_rate_array)
attack_rate_mean2=rep(NA,n_regions)
for(n_region in 1:n_regions){
  subset=subset(case_data,region==regions[n_region])
  attack_rate_mean2[n_region]=mean(subset$attack_rates[subset$cases>=1.0])
}
attack_rate_mean2[is.na(attack_rate_mean2)]=0.0

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

scale=c(0,1e-6,2.5e-6,5e-6,7.5e-6,1e-5,2.5e-5,5e-5,7.5e-5,1e-4,2.5e-4)

png("mean attack rate (all) map (seeding+R0).png",width=945.507,height=1440)
create_map(shape_data,attack_rate_mean1,scale=scale,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="Mean attack rate (all)",legend_position="bottomright",
           legend_format="e",legend_dp=1,output_file=NULL)
dev.off()

png("mean attack rate (modified) map (seeding+R0).png",width=945.507,height=1440)
create_map(shape_data,attack_rate_mean2,scale=scale,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="Mean attack rate (outbreaks)",legend_position="bottomright",
           legend_format="e",legend_dp=1,output_file=NULL)
dev.off()
