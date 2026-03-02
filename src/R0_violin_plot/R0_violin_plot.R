#Create violin plot of R0 values by region

library(ggplot2)

pars <- orderly2::orderly_parameters(query="latest")

orderly2::orderly_dependency(name="get_FOI_R0_values_from_saved_chain_data", 
                             query=pars$query,
                             files=c(DSY_selected_datasets_FOI_R0.Rds="DSY_selected_datasets_FOI_R0.Rds"))

orderly2::orderly_artefact(description="Plot", files=c("R0_violin.png"))

FOI_R0_values=readRDS(file="DSY_selected_datasets_FOI_R0.Rds")

n_regions=length(FOI_R0_values$regions)
n_values=dim(FOI_R0_values$R0)[1]

data_frame = data.frame(n_regions=as.factor(sort(rep(c(1:n_regions),n_values))),R0=as.vector(FOI_R0_values$R0[,,1]))
R0_limits=c(0,max(data_frame$R0)*1.05)
R0_labels=0.1*c(0:ceiling(R0_limits[2]/0.1))
text_size=24

png(filename="R0_violin.png",width=1440,height=960)
par(mar=c(4,4,1,1))
p_R0 <- ggplot(data=data_frame, aes(x=n_regions, y=R0)) + theme_bw()
p_R0 <- p_R0+geom_violin(trim=FALSE, scale="width")
p_R0 <- p_R0 + scale_x_discrete(name="", breaks=c(1:n_regions), labels=FOI_R0_values$regions)
p_R0 <- p_R0 + scale_y_continuous(name="R0", breaks=R0_labels, labels=R0_labels,limits=R0_limits)
p_R0 <- p_R0 + theme(axis.text.x = element_text(angle = 90, hjust=1, size=text_size),
                    axis.text.y = element_text(size = text_size),axis.title.y = element_text(size = text_size))
plot(p_R0)
par(mar=c(4,4,4,4))
dev.off()