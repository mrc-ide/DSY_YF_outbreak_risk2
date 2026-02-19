library(ggplot2)
library(YEPaux)

orderly_dependency(name="get_FOI_R0_values_from_saved_chain_data", query="latest", #TODO - make query input parameter
                   files=c(DSY_selected_datasets_FOI_R0.Rds="DSY_selected_datasets_FOI_R0.Rds"))

#Load new shape data and region cross-referencing table
orderly_shared_resource('shapefile_data_DSY_adm1.Rds' = 'shapefile_data_DSY_adm1.Rds',
                        'xref_adm1.Rds' = 'xref_adm1.Rds')

country_list=c("DJI","SOM","YEM")

dataset=readRDS(file="DSY_selected_datasets_FOI_R0.Rds")
FOI_R0_dist_data=get_FOI_R0_dist_data(dataset)

FOI_R0_dist_data[,c(3:8)]=FOI_R0_dist_data[,c(3:8)]*365.0 #Convert daily FOI to annual FOI
regions_gadm=FOI_R0_dist_data$region
country_list=unique(substr(regions_gadm,1,3))

shape_data=readRDS("shapefile_data_DSY_adm1.Rds")
regions_who=shape_data$region
xref_table=readRDS("xref_adm1.Rds")
#Create index to remap FOI/R0 values onto WHO regions
xref_index=rep(NA,length(regions_who))
for(i in 1:length(regions_who)){
  index1=which(xref_table$WHO_Name==regions_who[i])
  xref_index[i]=which(regions_gadm==xref_table$GADM_ID[index1])
}

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
  
  #Remap FOI/R0 values to new regions
  FOI_values2=FOI_values[xref_index]
  R0_values2=R0_values[xref_index]
  
  orderly_artefact(description=paste0("Figures ",data_select), files=c(paste0("epi_map_FOI_",data_type,".png"),
                                                                       paste0("epi_map_R0_",data_type,".png")))
  
  #png(paste0("epi_map_FOI_",data_type,".png"),width=945.507,height=1440)
  map_FOI=create_map(shape_data=shape_data,param_values=FOI_values2,text_size=5,
                     display_axes=FALSE,border_colour_regions = "grey",
                     scale_manual=scale_FOI,colour_scale_manual=colour_scale,
                     pixels_max=1440,map_title=NULL,legend_title="Spillover FOI (annual)",
                     legend_position=c(0.8,0.3),legend_format="e",legend_dp=1)
  map_FOI = map_FOI + theme(legend.key.size = unit(0.25, "cm"))
  #dev.off()
  ggsave(filename=paste0("epi_map_FOI_",data_type,".png"),plot=map_FOI,
         width=945.507,height=1440,units="px",bg="white")
  
  #png(paste0("epi_map_R0_",data_type,".png"),width=945.507,height=1440)
  map_R0=create_map(shape_data=shape_data,param_values=R0_values2,text_size=5,
                    display_axes=FALSE,border_colour_regions = "grey",
                    scale_manual=scale_R0,colour_scale_manual=colour_scale,
                    pixels_max=1440,map_title=NULL,legend_title="Basic rep. number",
                    legend_position=c(0.8,0.15),legend_format="f",legend_dp=2)
  map_R0 = map_R0 + theme(legend.key.size = unit(0.25, "cm"))
  ggsave(filename=paste0("epi_map_R0_",data_type,".png"),plot=map_R0,
         width=945.507,height=1440,units="px",bg="white")
  #dev.off()
}
