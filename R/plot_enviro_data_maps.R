#library(YEPaux)
devtools::load_all("C:/Users/kjfras16/Documents/GitHub/YEPaux")
path=getwd() #Adjust if not using project file
shapefile_folder="C:/Users/kjfras16/Documents/00 - Big data files to back up infrequently/00 - GADM36 shapefiles"
enviro_data=read.csv("shared/enviro_data_IAregions_6covs_new_labelling.csv",header=TRUE)
colour_scale=readRDS("shared/colour_scheme_example.Rds")$colour_scale

#Load covariate data and get ranges
{
  covariates=colnames(enviro_data)[c(2:ncol(enviro_data))]
  n_covs=length(covariates)
  cov_data=list()
  for(i in 1:n_covs){
    cov_data[[i]]=list(name=c(),range=c(),scale=c(),format="",dp=0)
    cov_data[[i]]$name=covariates[i]
    cov_data[[i]]$range=pretty(enviro_data[,i+1],10)
  }
  cov_data
}

#Set scales and formats
{
  #aegypti
  cov_data[[1]]$scale=c(0:1)
  cov_data[[1]]$format="integer"
  #LC10
  cov_data[[2]]$scale=0.2*c(0:5)
  cov_data[[2]]$format="f"
  cov_data[[2]]$dp=1
  #logpop
  cov_data[[3]]$scale=0.5*c(9:14)
  cov_data[[3]]$format="f"
  cov_data[[3]]$dp=1
  #MIR.max
  cov_data[[4]]$scale=0.1*c(4:10)
  cov_data[[4]]$format="f"
  cov_data[[4]]$dp=1
  #nhps_combined
  cov_data[[5]]$scale=c(0:4)
  cov_data[[5]]$format="integer"
  #temp_suit_mean
  cov_data[[6]]$scale=10*c(0:6)
  cov_data[[6]]$format="f"
  cov_data[[6]]$dp=0
  
}

regions=enviro_data$region
country_list=unique(substr(regions,1,3))
shapefiles=shapefiles_countries=rep("",length(country_list))
for(i in 1:length(country_list)){
  shapefiles[i]=paste(shapefile_folder,"/",country_list[i],"/gadm36_",country_list[i],"_1.shp",sep="")
  shapefiles_countries[i]=paste(shapefile_folder,"/",country_list[i],"/gadm36_",country_list[i],"_0.shp",sep="")
}
shape_data=YEPaux::map_shapes_load(regions, shapefiles, region_label_type="GID_1")
shape_data_countries=YEPaux::map_shapes_load(country_list, shapefiles_countries, region_label_type="GID_0")

par(mfrow=c(2,3),mar=c(1,1,1,1))
for(i in 1:n_covs){
  create_map(shape_data,enviro_data[,i+1],scale=cov_data[[i]]$scale,colour_scale,pixels_max=720,
             text_size=1.0,border_colour_regions="light grey",map_title=covariates[i],
             border_colour_additional="black",legend_title=NULL,legend_position="bottomright",
             additional_border_shapes=shape_data_countries,legend_format=cov_data[[i]]$format,
             legend_dp=cov_data[[i]]$dp,
             output_file=NULL) #output_file=paste0("shared/DSY_enviro_map",i,".png")) 
}
par(mfrow=c(1,1),mar=c(4,4,4,4))