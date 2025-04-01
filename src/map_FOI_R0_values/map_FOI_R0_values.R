#orderly2::orderly_parameters(scale_FOI=NULL,scale_R0=NULL)

orderly2::orderly_dependency(name="get_FOI_R0_values_from_saved_chain_data", query="latest", #TODO - make query input parameter
                             files=c(DSY_selected_datasets_FOI_R0.Rds="DSY_selected_datasets_FOI_R0.Rds"))


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

#library(YEPaux)
country_list=c("DJI","SOM","YEM")

dataset=readRDS(file="DSY_selected_datasets_FOI_R0.Rds")
FOI_R0_dist_data=YEPaux::get_FOI_R0_dist_data(dataset)

FOI_R0_dist_data[,c(3:8)]=FOI_R0_dist_data[,c(3:8)]*365.0 #Convert daily FOI to annual FOI
regions=FOI_R0_dist_data$region
country_list=unique(substr(regions,1,3))

shapefiles=rep("",length(country_list))
for(i in 1:length(country_list)){
  shapefiles[i]=paste0("shapefiles/",country_list[i],"/gadm36_",country_list[i],"_1.shp")
}
shape_data=YEPaux::map_shapes_load(regions, shapefiles, region_label_type="GID_1")

colour_scale=readRDS(file=paste(path.package("YEPaux"), "exdata/colour_scheme_example.Rds", sep="/"))$colour_scale
#scale_FOI=pretty(as.vector(t(FOI_R0_dist_data[,c(3:6)])),10)
#scale_R0=pretty(as.vector(t(FOI_R0_dist_data[,c(10:13)])),10)
scale_FOI=c(0,1e-7,1e-6,5e-6,1e-5,2.5e-5,5e-5,1e-4,1.5e-4,2e-4,2.5e-4,3e-4,3.5e-4,4e-4)
scale_R0=c(0,0.5,0.6,0.7,0.8,0.85,0.9,0.95,1.0,1.05,1.1,1.15)

data_types=c("2_5pc","25pc","median","75pc","97_5pc","mean")

for(data_select in c(1,2,3,4,5)){
  data_type=data_types[data_select]
  FOI_values=FOI_R0_dist_data[,2+data_select]
  R0_values=FOI_R0_dist_data[,9+data_select]
  
  orderly2::orderly_artefact(description=paste0("Figures ",data_select), files=c(paste0("epi_map_FOI_",data_type,".png"),
                                                                                 paste0("epi_map_R0_",data_type,".png")))
  
  
  png(paste0("epi_map_FOI_",data_type,".png"),width=945.507,height=1440)
  YEPaux::create_map(shape_data,FOI_values,scale=scale_FOI,colour_scale,pixels_max=1440,
                     text_size=2,map_title="",legend_title="Spillover force of infection (annual)",legend_position="bottomright",
                     legend_format="e",legend_dp=1,output_file=NULL)
  dev.off()
  
  png(paste0("epi_map_R0_",data_type,".png"),width=945.507,height=1440)
  YEPaux::create_map(shape_data,R0_values,scale=scale_R0,colour_scale,pixels_max=1440,
                     text_size=2,map_title="",legend_title="Basic reproduction number",legend_position="bottomright",
                     legend_format="f",legend_dp=2,output_file=NULL)
  dev.off()
  
  
}
