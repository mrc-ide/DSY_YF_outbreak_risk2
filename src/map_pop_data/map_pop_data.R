orderly2::orderly_shared_resource("input_data.Rds"="input_data.Rds")

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

input_data=readRDS(file="input_data.Rds")
years_data=c(2023)
n_years=length(years_data)
years_input_required=c(years_data[1]:(max(years_data)+1))
n_years_input_required=c(1:length(input_data$years_labels))[input_data$years_labels %in% years_input_required]

input_data_reduced=list(region_labels=input_data$region_labels,years_labels=input_data$years_labels[n_years_input_required],
                        age_labels=input_data$age_labels,vacc_data=input_data$vacc_data[,n_years_input_required,],
                        pop_data=input_data$pop_data[,n_years_input_required,])

pop_values=rowSums(input_data_reduced$pop_data[,1,])

country_list=unique(substr(regions,1,3))
shapefiles=rep("",length(country_list))
for(i in 1:length(country_list)){
  shapefiles[i]=paste("shapefiles/",country_list[i],"/gadm36_",country_list[i],"_1.shp",sep="")
}
shape_data=map_shapes_load(regions, shapefiles, region_label_type="GID_1")

colour_scheme=readRDS(file=paste(path.package("YEPaux"), "exdata/colour_scheme_example.Rds", sep="/"))
colour_scale=colour_scheme$colour_scale

scale=c(0,5e4,1e5,2.5e5,5e5,7.5e5,1e6,2.5e6,5e6)
png("Population map.png",width=945.507,height=1440)
create_map(shape_data,pop_values,scale=scale,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="Population",legend_position="bottomright",
           legend_format="e",legend_dp=1,output_file=NULL)
dev.off()