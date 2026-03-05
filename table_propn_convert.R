path=getwd() #Adjust if not using project file

table_gadm=read.csv(file=paste0(path,"/shared/table_propn.csv"),header=TRUE)

xref_adm1=readRDS(file=paste0(path,"/shared/xref_adm1.Rds"))
xref_adm2=readRDS(file=paste0(path,"/shared/xref_adm2.Rds"))

table_new=table_gadm
colnames(table_new)[1]="Country"
table_new=cbind(table_new,array("",dim=c(nrow(table_new),3)))
colnames(table_new)[c(5:7)]=c("adm1_who","adm2_who","flag_multi")
table_new$flag_multi=FALSE

for(i in 1:nrow(table_new)){
  adm1_names=xref_adm1$WHO_Name[which(xref_adm1$GADM_Name==table_gadm$Province[i])]
  table_new$adm1_who[i]=paste(adm1_names,collapse=",")
  adm2_names=xref_adm2$WHO_Name[which(xref_adm2$GADM_Name==table_gadm$District[i])]
  table_new$adm2_who[i]=paste(adm2_names,collapse=",")
  if(length(adm1_names)>1 || length(adm2_names)>1){table_new$flag_multi[i]=TRUE}
}

table_new[table_new$flag_multi==TRUE,c(1:3,5:6)]
#which(table_new$flag_multi==TRUE) #2,3,4,10,11,12,14,18,19
table_new[10,]

table_new$adm1_who[2]="KARKAR"
table_new$adm2_who[2]="GARDO"
table_new$adm1_who[3]="KARKAR"
table_new$adm2_who[3]="HAFUN"
table_new$adm1_who[4]="BARI"
table_new$adm2_who[4]="QANDALA"
table_new$adm1_who[10]=""
table_new$adm2_who[10]=""
table_new$adm1_who[11]=""
table_new$adm2_who[11]=""
table_new$adm1_who[12]=""
table_new$adm2_who[12]=""
table_new$adm1_who[14]=""
table_new$adm2_who[14]=""
table_new$adm1_who[18]=""
table_new$adm2_who[18]=""
table_new$adm1_who[19]=""
table_new$adm2_who[19]=""