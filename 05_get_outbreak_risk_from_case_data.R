library(YEPaux)

case_data=readRDS(file="results/case_data01.Rds")
{
  regions=case_data$region
  n_regions=length(case_data$regions)
  n_param_sets=dim(case_data$cases)[2]
  
  shapefile_folder="Documents/00 - Big data files to back up infrequently/00 - GADM36 shapefiles"
  country_list=unique(substr(regions,1,3))
  shapefiles=rep("",length(country_list))
  for(i in 1:length(country_list)){
    shapefiles[i]=paste("shapefiles/",country_list[i],"/gadm36_",country_list[i],"_1.shp",sep="")
  }
  shape_data=map_shapes_load(regions, shapefiles, region_label_type="GID_1")
  colour_scheme=readRDS(file=paste(path.package("YEPaux"), "exdata/colour_scheme_example.Rds", sep="/"))
  colour_scale=colour_scheme$colour_scale
  scale=c(0,0.01,0.05,0.1,0.25,0.5,0.75,0.9,0.95,0.99,1.0)
}

outbreak_risk=rep(0,n_regions)
for(n_region in 1:n_regions){
  for(n_param_set in 1:n_param_sets){
    if(case_data$cases[n_region,n_param_set]>=1.0){outbreak_risk[n_region]=outbreak_risk[n_region]+1}
  }
  outbreak_risk[n_region]=min(1.0,outbreak_risk[n_region]/n_param_sets)
}

create_map(shape_data,outbreak_risk,scale=scale,colour_scale,pixels_max=1440,
           text_size=2,map_title="",legend_title="Outbreak risk",legend_position="bottomright",
           legend_format="f",legend_dp=2,output_file="maps/outbreak risk map.png")
