library(YEPaux)

#Get case data
case_data=readRDS(file="results/case_data_seeded_R0_1000_datasets.Rds")
regions=unique(case_data$region)
n_regions=length(regions)
n_param_sets=nrow(case_data)/n_regions
cases_array=array(case_data$cases,dim=c(n_regions,n_param_sets))

#Get population data
popvac_data=readRDS(file="exdata/input_data_DSY_2022_2050.Rds")
pop_data=rowSums(popvac_data$pop_data[,1,])

#Convert case and population data to attack rate
p_severe_inf=0.12
infs_array=cases_array/p_severe_inf
attack_rate_array=infs_array/pop_data
attack_rate_mean=rowMeans(attack_rate_array)

shapefile_folder="Documents/00 - Big data files to back up infrequently/00 - GADM36 shapefiles"
country_list=unique(substr(regions,1,3))
shapefiles=rep("",length(country_list))
for(i in 1:length(country_list)){
  shapefiles[i]=paste("shapefiles/",country_list[i],"/gadm36_",country_list[i],"_1.shp",sep="")
}
shape_data=map_shapes_load(regions, shapefiles, region_label_type="GID_1")
colour_scheme=readRDS(file=paste(path.package("YEPaux"), "exdata/colour_scheme_example.Rds", sep="/"))
colour_scale=colour_scheme$colour_scale

scale=c(0,1e-6,2.5e-6,5e-6,1e-5,2.5e-5,5e-5,1e-4,2.5e-4)
create_map(shape_data,attack_rate_mean,scale=scale,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="Attack rate",legend_position="bottomright",
           legend_format="e",legend_dp=1,output_file="maps/mean attack rate map (seeding+R0).png")
