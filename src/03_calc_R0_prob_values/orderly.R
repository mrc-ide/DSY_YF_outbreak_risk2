orderly2::orderly_dependency(name="01_get_FOI_R0_values_from_saved_chain_data", 
                             query="latest",
                             files=c(DSY_1000_datasets.Rds="DSY_1000_datasets_FOI_R0.Rds"))

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

orderly2::orderly_artefact(description="All figures",files=c("map_p_R0_05.png", "map_p_R0_07.png", "map_p_R0_10.png"))

library(YEPaux)
library(dplyr)

dataset=readRDS(file="DSY_1000_datasets.Rds")

# R0_prob_data=data.frame(region=regions,p_05=rep(NA,n_regions),p_07=rep(NA,n_regions),p_1=rep(NA,n_regions))
# for(n_region in 1:n_regions){
#   R0_values=sort(dataset$R0[n_region,])
#   R0_prob_data$p_05[n_region]=1-(findInterval(0.5,R0_values)/n_entries)
#   R0_prob_data$p_07[n_region]=1-(findInterval(0.7,R0_values)/n_entries)
#   R0_prob_data$p_1[n_region]=1-(findInterval(1.0,R0_values)/n_entries)
# }
R0_prob_data <- dataset %>%
  group_by(region) %>%
  summarise(p_05 = sum(R0>=0.5)/n(),
            p_07 = sum(R0>=0.7)/n(),
            p_1  = sum(R0>=1)  /n() )


country_list=unique(substr(regions,1,3))
shapefiles=rep("",length(country_list))
for(i in 1:length(country_list)){
  shapefiles[i]=paste0("shapefiles/",country_list[i],"/gadm36_",country_list[i],"_1.shp")
}
shape_data=map_shapes_load(R0_prob_data$region, shapefiles, region_label_type="GID_1")
colour_scheme=readRDS(file=paste(path.package("YEPaux"), "exdata/colour_scheme_example.Rds", sep="/"))
colour_scale=colour_scheme$colour_scale

scale=c(0,0.01,0.05,0.1,0.25,0.5,0.75,0.9,0.95,0.99,1.0)

create_map(shape_data,R0_prob_data$p_05,scale=scale,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="P(R0>=0.5)",legend_position="bottomright",
           legend_format="f",legend_dp=2,output_file="map_p_R0_05.png")

create_map(shape_data,R0_prob_data$p_07,scale=scale,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="P(R0>=0.7)",legend_position="bottomright",
           legend_format="f",legend_dp=2,output_file="map_p_R0_07.png")

create_map(shape_data,R0_prob_data$p_1,scale=scale,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="P(R0>=1.0)",legend_position="bottomright",
           legend_format="f",legend_dp=2,output_file="map_p_R0_10.png")
