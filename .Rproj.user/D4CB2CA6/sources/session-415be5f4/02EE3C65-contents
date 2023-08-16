library(YEPaux)
country_list=c("DJI","SOM","YEM")

dataset=readRDS(file="exdata/DSY_1000_datasets_FOI_R0.Rds")
FOI_R0_dist_data=YEPaux::get_FOI_R0_dist_data(dataset)

FOI_R0_dist_data[,c(3:8)]=FOI_R0_dist_data[,c(3:8)]*365.0 #Convert daily FOI to annual FOI
regions=FOI_R0_dist_data$region
country_list=unique(substr(regions,1,3))

shapefiles=rep("",length(country_list))
for(i in 1:length(country_list)){
  shapefiles[i]=paste0("shapefiles/",country_list[i],"/gadm36_",country_list[i],"_1.shp")
}
shape_data=map_shapes_load(regions, shapefiles, region_label_type="GID_1")

colour_scheme=readRDS(file=paste(path.package("YEPaux"), "exdata/colour_scheme_example.Rds", sep="/"))
colour_scale=colour_scheme$colour_scale
scale_FOI=c(0,1e-7,1e-6,1e-5,5e-5,1e-4,2.5e-4,5e-4)
scale_R0=c(0,0.5,0.6,0.7,0.8,0.9,1.0,1.1)

data_types=c("2_5pc","25pc","50pc","75pc","97_5pc","mean")

for(data_select in 1:6){
  data_type=data_types[data_select]
  FOI_values=FOI_R0_dist_data[,2+data_select]
  R0_values=FOI_R0_dist_data[,9+data_select]
  
  create_map(shape_data,FOI_values,scale=scale_FOI,colour_scale,pixels_max=720,
             text_size=1,map_title="",legend_title="Spillover force of infection (annual)",legend_position="bottomright",
             legend_format="e",legend_dp=1,output_file=paste0("maps/FOI_map",data_type,".png"))
  
  create_map(shape_data,R0_values,scale=scale_R0,colour_scale,pixels_max=720,
             text_size=1,map_title="",legend_title="Basic reproduction number",legend_position="bottomright",
             legend_format="f",legend_dp=1,output_file=paste0("maps/R0_map",data_type,".png"))
  
}
