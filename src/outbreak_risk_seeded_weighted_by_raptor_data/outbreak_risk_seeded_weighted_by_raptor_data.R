pars = orderly2::orderly_parameters(raptor_results_filename="")

orderly2::orderly_dependency(name="case_data_calc_R0_case_seeding",query="latest", #TODO - make query input parameter
                             files=c("case_data_seeded_R0_selected_datasets.Rds"))

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
                                  
                                  'shapefiles/DJI/gadm36_DJI_2.cpg' = 'shapefiles/DJI/gadm36_DJI_2.cpg', 
                                  'shapefiles/DJI/gadm36_DJI_2.dbf' = 'shapefiles/DJI/gadm36_DJI_2.dbf', 
                                  'shapefiles/DJI/gadm36_DJI_2.prj' = 'shapefiles/DJI/gadm36_DJI_2.prj', 
                                  'shapefiles/DJI/gadm36_DJI_2.shp' = 'shapefiles/DJI/gadm36_DJI_2.shp', 
                                  'shapefiles/DJI/gadm36_DJI_2.shx' = 'shapefiles/DJI/gadm36_DJI_2.shx', 
                                  'shapefiles/SOM/gadm36_SOM_2.cpg' = 'shapefiles/SOM/gadm36_SOM_2.cpg', 
                                  'shapefiles/SOM/gadm36_SOM_2.dbf' = 'shapefiles/SOM/gadm36_SOM_2.dbf', 
                                  'shapefiles/SOM/gadm36_SOM_2.prj' = 'shapefiles/SOM/gadm36_SOM_2.prj',
                                  'shapefiles/SOM/gadm36_SOM_2.shp' = 'shapefiles/SOM/gadm36_SOM_2.shp', 
                                  'shapefiles/SOM/gadm36_SOM_2.shx' = 'shapefiles/SOM/gadm36_SOM_2.shx',
                                  
                                  "raptor_results.rds" = pars$raptor_results_filename)

library(YEPaux)

country_list=c("DJI","SOM")
case_data=readRDS(file="case_data_seeded_R0_selected_datasets.Rds")
case_data_selected=subset(case_data,substr(region,1,3) %in% country_list)
adm1_regions=unique(case_data_selected$region)
n_adm1_regions=length(adm1_regions)
n_param_sets=nrow(case_data_selected)/n_adm1_regions
cases_array=array(case_data_selected$cases,dim=c(n_adm1_regions,n_param_sets))

shapefiles1=shapefiles2=rep("",length(country_list))
adm2_regions=c()
for(i in 1:length(country_list)){
  shapefiles1[i]=paste("shapefiles/",country_list[i],"/gadm36_",country_list[i],"_1.shp",sep="")
  shapefiles2[i]=paste("shapefiles/",country_list[i],"/gadm36_",country_list[i],"_2.shp",sep="")
  shape=sf::read_sf(shapefiles2[i])
  adm2_regions=append(adm2_regions,shape$GID_2)
}
n_adm2_regions=length(adm2_regions)
shape_data1=map_shapes_load(adm1_regions, shapefiles1, region_label_type="GID_1")
shape_data2=map_shapes_load(adm2_regions, shapefiles2, region_label_type="GID_2")
colour_scheme=readRDS(file=paste(path.package("YEPaux"), "exdata/colour_scheme_example.Rds", sep="/"))
colour_scale=colour_scheme$colour_scale

outbreak_risk_adm1=rep(0,n_adm1_regions)
for(n_adm1 in 1:n_adm1_regions){
  for(n_param_set in 1:n_param_sets){
    if(cases_array[n_adm1,n_param_set]>=1.0){outbreak_risk_adm1[n_adm1]=outbreak_risk_adm1[n_adm1]+1}
  }
  outbreak_risk_adm1[n_adm1]=min(1.0,outbreak_risk_adm1[n_adm1]/n_param_sets)
}

raptor_data=readRDS(file="raptor_results.rds")
raptor_data_adm1_names=unique(raptor_data$Province)
raptor_data_adm2_numbers=unique(raptor_data$District_id)
raptor_data_adm2_names=unique(raptor_data$District)

blank=rep(NA,n_adm2_regions)
outbreak_risk_adm2=rt_risk_scores_mean_adm2=rt_risk_scores_median_adm2=rel_outbreak_risk_adm2_a=rel_outbreak_risk_adm2_b=blank
for(n_adm2 in 1:n_adm2_regions){
  subset=subset(raptor_data,District==raptor_data_adm2_names[n_adm2])
  rt_risk_scores_mean_adm2[n_adm2]=mean(subset$risk_score)
  rt_risk_scores_median_adm2[n_adm2]=median(subset$risk_score)
  adm2_label=unique(subset$District_id)
  adm1_label=paste0(paste0(strsplit(adm2_label, "_")[[1]][c(1,2)], collapse = "."),"_1",sep="")
  n_adm1=c(1:n_adm1_regions)[adm1_regions==adm1_label]
  outbreak_risk_adm2[n_adm2]=outbreak_risk_adm1[n_adm1]
  rel_outbreak_risk_adm2_a[n_adm2]=rt_risk_scores_mean_adm2[n_adm2]*outbreak_risk_adm2[n_adm2]
  rel_outbreak_risk_adm2_b[n_adm2]=rt_risk_scores_median_adm2[n_adm2]*outbreak_risk_adm2[n_adm2]
}

#Checking that adm1 and adm2 outbreak risk maps match
# png("Risk maps adm1+adm2.png",width=2*945.507,height=1440)
# par(mfrow=c(1,2))
# scale=c(0,0.01,0.05,0.1,0.25,0.5,0.75,0.9,0.95,0.99,1.0001)
# create_map(shape_data1,outbreak_risk_adm1,scale=scale,colour_scale,pixels_max=1440,text_size=1,map_title="",
#            legend_title="Outbreak risk",legend_position="bottomright",legend_format="f",legend_dp=2,NULL)
# create_map(shape_data2,outbreak_risk_adm2,scale=scale,colour_scale,pixels_max=1440,text_size=1,map_title="",
#            legend_title="Outbreak risk",legend_position="bottomright",legend_format="f",legend_dp=2,NULL)
# par(mfrow=c(1,1))
# dev.off()
# 
# scale=c(0,1e-3,5e-3,1e-2,5e-2,1e-1,5e-1,1,5,10,50,100.0001)
# png("Raptor relative transmission risk - mean by district.png",width=945.507,height=1440)
# create_map(shape_data2,rt_risk_scores_mean_adm2,scale=scale,colour_scale,pixels_max=1440,text_size=2,map_title="",
#            legend_title="Mean relative transmission risk",legend_position="bottomright",legend_format="e",legend_dp=1,
#            output_file=NULL)
# dev.off()
# png("Raptor relative transmission risk - median by district.png",width=945.507,height=1440)
# create_map(shape_data2,rt_risk_scores_median_adm2,scale=scale,colour_scale,pixels_max=1440,text_size=2,map_title="",
#            legend_title="Median relative transmission risk",legend_position="bottomright",legend_format="e",legend_dp=1,
#            output_file=NULL)
# dev.off()
# 
# scale=c(0,1e-4,1e-3,1e-2,3e-2,1e-1,3e-1,1,2,3)
# png("Relative outbreak risk due to seeded case x mean relative transmission risk.png",width=945.507,height=1440)
# create_map(shape_data2,rel_outbreak_risk_adm2_a,scale=scale,colour_scale,pixels_max=1440,text_size=2,map_title="",
#            legend_title="Relative outbreak risk",legend_position="bottomright",legend_format="e",legend_dp=1,
#         output_file=NULL)
# dev.off()
# png("Relative outbreak risk due to seeded case x median relative transmission risk.png",width=945.507,height=1440)
# create_map(shape_data2,rel_outbreak_risk_adm2_b,scale=scale,colour_scale,pixels_max=1440,text_size=2,map_title="",
#            legend_title="Relative outbreak risk",legend_position="bottomright",legend_format="e",legend_dp=1,
#            output_file=NULL)
# dev.off()
