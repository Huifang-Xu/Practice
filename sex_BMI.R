##practice: 10/10/2021
#read data
df_ukb34137 <- read.table("ukb34137.tab",header=TRUE, sep="\t")
df_ukb37330 <- read.table("ukb37330.tab",header=TRUE, sep="\t")
df_join <- as_tibble(inner_join(df_ukb34137, df_ukb37330, 
                                by=intersect(colnames(df_ukb34137), colnames(df_ukb37330))))
#extract data: sex (code: f.31.0.0), BMI (code: f.21001.0.0)
df_sex_BMI <- select(df_join,f.eid,f.31.0.0,f.21001.0.0)
#extract BMI and sex colums

#count the number of female and male, median BMI of female and male
num_female <- nrow(subset(df,f.31.0.0==0))
num_male <- nrow(subset(df,f.31.0.0==1))
female_median_BMI <- median(subset(df_sex_BMI,f.31.0.0==0)$f.21001.0.0,na.rm = TRUE)
male_median_BMI <- median(subset(df_sex_BMI,f.31.0.0==1)$f.21001.0.0,na.rm = TRUE)

#boxplot
library(ggplot2)
library(ggpubr)
annotation <- data.frame(x=c(1.5,2.5,1,2),
                         y=c(female_median_BMI,male_median_BMI,78,78),
                         label=c(female_median_BMI,male_median_BMI,paste("n = ",num_female),paste("n = ",num_male)))
pdf("sex_BMI.pdf",width = 6,height = 8)
ggplot(df_sex_BMI,aes(x=factor(f.31.0.0),y=f.21001.0.0))
  +geom_boxplot(aes(fill=factor(f.31.0.0,levels = c("0", "1"),labels = c("Female","Male"))))
  +theme_bw()
  +theme(panel.background = element_blank(),panel.grid.major = element_blank(),panel.grid.minor = element_blank(),legend.position=c(0.88,0.85), legend.title=element_blank())
  +scale_x_discrete(limits=c("0","1"), labels=c( "Female","Male"))
  +xlab("Sex") 
  +ylab("BMI")
  +ggtitle(title="Interaction between Sex and BMI")
  +stat_summary(fun.y = "mean",geom="point",fill="white",shape=21,size=4)
  +stat_compare_means(method="t.test",label.x = 1.2,label.y = 70)
  +geom_text(data=annotation,aes(x=x, y=y, label=label),size=4)
dev.off()
