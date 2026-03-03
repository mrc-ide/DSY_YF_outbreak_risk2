#Create map of starting locations for RAPTORX human movement simulation

library(ggplot2)

pars <- orderly2::orderly_parameters(count_file = "", xref_file = "", shapefile = "")

count_data = readRDS(pars$count_file)

xref_table = readRDS(pars$xref_file)

shape_data = readRDS(pars$shapefile)

n_regions=length(shape_data$region)
map_fill_values=rep(0,n_regions)
for(i in 1:(nrow(count_data)-1)){
  index=which(shape_data$region == count_data$WHO_name[i])
  assertthat::assert_that(length(index)==1)
  map_fill_values[index]=count_data$count[i]
}
scale_count=c(0,1,2,4,8,12)
palette=MetBrewer::met.brewer("Hiroshige")
colour_scale=c("white",as.vector(palette)[6:10])
map1=create_map(shape_data=shape_data,param_values=map_fill_values,text_size=8,
                display_axes=FALSE,border_colour_regions = "grey",
                scale_manual=scale_count,colour_scale_manual=colour_scale,
                map_title=NULL,legend_title=NULL,
                legend_position=NULL)
map1 <- map1 + guides(fill="none")

bbox=sf::st_bbox(shape_data)
lat_max=bbox$ymax
lat_min=bbox$ymin
ydim=lat_max-lat_min
long_max=bbox$xmax
long_min=bbox$xmin
xdim=long_max-long_min

ggsave(filename="raptorx_start_loc.png",plot=map1,
       width=1440*(xdim/ydim),height=1440,units="px",bg="white")
