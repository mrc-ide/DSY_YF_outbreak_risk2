source("R/temp_suit.R")

param_data=read.csv(file="R/temp_suit_parm.csv")
param_values=param_data$x
names(param_values)=param_data$X

temp=c(5:31)

temp_suit=temp_suitability(temp,param_values)

plot(temp,temp_suit)

enviro_data=read.csv(file="exdata/enviro_data_IAregions_6covs_old_labelling_ts_error.csv",header=TRUE)
temp=enviro_data$temp_suit_mean
temp_suit=temp_suitability(temp,param_values)

b=17.5
a=5.5

matplot(x=temp,y=temp_suit,type="p",pch=1)
matplot(x=temp,y=a*(temp-b),type="l",col=2,add=TRUE)