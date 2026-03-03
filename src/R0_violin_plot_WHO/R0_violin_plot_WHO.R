#Create violin plot of R0 values by region (adjusted to add WHO regions)

library(ggplot2)

pars <- orderly2::orderly_parameters(epi_id="latest", xref_file = "")

orderly2::orderly_dependency(name="get_FOI_R0_values_from_saved_chain_data", 
                             query=pars$epi_id,
                             files=c(DSY_selected_datasets_FOI_R0.Rds="DSY_selected_datasets_FOI_R0.Rds"))

orderly2::orderly_artefact(description="Plot", files=c("R0_violin.png"))

FOI_R0_values=readRDS(file="DSY_selected_datasets_FOI_R0.Rds")
regions_gadm=FOI_R0_values$regions
n_values=dim(FOI_R0_values$R0)[1]

xref_table=readRDS(pars$xref_file)
regions_who=xref_table$WHO_Name
n_regions=length(regions_who)
#Create index to remap FOI/R0 values onto WHO regions
xref_index=country_index=rep(NA,n_regions)
for(i in 1:length(regions_who)){
  index1=which(xref_table$WHO_Name==regions_who[i])
  gadm_id=xref_table$GADM_ID[index1]
  xref_index[i]=which(regions_gadm==gadm_id)
  country_index[i]=substr(gadm_id,1,3)
}

#Remap FOI/R0 values to new regions
R0_values2=array(NA,dim=c(n_values,n_regions,1))
for(i in 1:n_values){
  R0_values2[i,,1]=FOI_R0_values$R0[i,xref_index,1]
}

data_frame = data.frame(n_regions=as.factor(sort(rep(c(1:n_regions),n_values))),R0=as.vector(R0_values2[,,1]))
R0_limits=c(0,max(data_frame$R0)*1.05)
R0_labels=0.1*c(0:ceiling(R0_limits[2]/0.1))
region_labels=paste0(country_index," - ",regions_who)
text_size=24

png(filename="R0_violin.png",width=1440,height=960)
par(mar=c(4,4,1,1))
p_R0 <- ggplot(data=data_frame, aes(x=n_regions, y=R0)) + theme_bw()
p_R0 <- p_R0+geom_violin(trim=FALSE, scale="width")
p_R0 <- p_R0 + scale_x_discrete(name="", breaks=c(1:n_regions), labels=region_labels)
p_R0 <- p_R0 + scale_y_continuous(name="R0", breaks=R0_labels, labels=R0_labels,limits=R0_limits)
p_R0 <- p_R0 + theme(axis.text.x = element_text(angle = 90, hjust=1, size=text_size),
                    axis.text.y = element_text(size = text_size),axis.title.y = element_text(size = text_size))
plot(p_R0)
par(mar=c(4,4,4,4))
dev.off()