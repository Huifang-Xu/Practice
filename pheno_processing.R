R: processing ICD-10 and Sex information
library(tidyverse)
#read data


#R function manyColsToDummy
manyColsToDummy<-function(search_terms, search_columns,
                          output_table){
    #initialize output table
    temp_table<-data.frame(matrix(ncol=length(search_terms),
                                  nrow= nrow(search_columns)))
    colnames(temp_table)<-search_terms
    
    #make table
    for (i in 1:length(search_terms)){
        vec<-rowSums(sapply(search_columns,
                            function(x) grepl(search_terms[i], x, ignore.case = TRUE)
        ))>0
        temp_table[,i]<-vec
    }
    temp_table<-sapply(temp_table, as.integer, as.logical)
    temp_table<-as.data.frame(temp_table)
    assign(x = output_table, value = temp_table, envir = globalenv())
}

searchcols <- 
manyColsToDummy("K739",df_split[,3:215],"sum_icd10_table")

df_merge <- data.frame(df_split[,1:2],sum_icd10_table)

write.table(df_merge,file="ukb34137_icd10_K739_sex.txt",sep='\t',row.names = FALSE)

#library(ggplot2)
#ggplot(df_merge,aes(x=factor(K739),fill=factor(f.31.0.0,levels = c("0", "1"),labels = c("Female","Male"))))+
#  geom_bar(position="dodge")+
#  theme( legend.title=element_blank())

#Count sample number by sex and phenotype
female_K739_0 <- nrow(subset(df,f.31.0.0==0 & K739==0))
female_K739_1 <- nrow(subset(df,f.31.0.0==0 & K739==1))
male_K739_0 <- nrow(subset(df,f.31.0.0==1 & K739==0))
male_K739_1 <- nrow(subset(df,f.31.0.0==1 & K739==1))

#barplot data processing
male <- c(male_K739_0,male_K739_1)
female <- c(female_K739_0,female_K739_1)
data <- rbind(female,male)
colnames(data) <- c("0","1")
newdata<-data
newdata[newdata>220000]<-newdata[newdata>220000]/1820 #Set the proportion

#Barplot
library(plotrix)
pdf("UKB_ICD10K739_Sex2.pdf",height = 6,width = 8)
barpos<-barplot(newdata,names.arg=colnames(newdata),
                ylim=c(0,180),
                beside=TRUE,col=c("red","darkblue"),
                axes=FALSE,
                xlab = "Chronic hepatitis (K739)",
                legend.text = c("Female","Male"))
axis(2,
     at=c(0,20,40,60,80,100,120,140,160,180),
     labels=c(0,20,40,60,80,100,120,250000,300000,350000));
box()
axis.break(2,120,style="gap") #set break
text(barpos,
     newdata+10,
     c(female_K739_0,male_K739_0,female_K739_1,male_K739_1)) #add text on barplot
dev.off()

##practice: 10/10/2021
#read data
df_ukb34137 <- read.table("ukb34137.tab",header=TRUE, sep="\t")
df_ukb37330 <- read.table("ukb37330.tab",header=TRUE, sep="\t")
df_join <- as_tibble(inner_join(df_ukb34137, df_ukb37330, 
                                by=intersect(colnames(df_ukb34137), colnames(df_ukb37330))))
#extract data: sex (code: f.31.0.0), BMI (code: f.21001.0.0)
df_sex_BMI <- select(df_join,f.eid,f.31.0.0,f.21001.0.0)
#extract BMI and sex colums
#read data
df_ukb34137 <- read.table("ukb34137.tab",header=TRUE, sep="\t")
df_ukb37330 <- read.table("ukb37330.tab",header=TRUE, sep="\t")
df_join <- as_tibble(inner_join(df_ukb34137, df_ukb37330, 
                                by=intersect(colnames(df_ukb34137), colnames(df_ukb37330))))
df_sex_BMI <- select(df_join,f.eid,f.31.0.0,f.21001.0.0)

#count the number of female and male, median BMI of female and male
num_female <- nrow(subset(df,f.31.0.0==0))
num_male <- nrow(subset(df,f.31.0.0==1))
female_median <- median(subset(df_sex_BMI,f.31.0.0==0)$f.21001.0.0,na.rm = TRUE)
male_median <- median(subset(df_sex_BMI,f.31.0.0==1)$f.21001.0.0,na.rm = TRUE)

#boxplot
library(ggplot2)
annotation <- data.frame(x=c(1.5,2.5,1,2),
                         y=c(female_median,male_median,78,78),
                         label=c(female_median,male_median,paste("n = ",num_female),paste("n = ",num_male)))
pdf("sex_BMI.pdf",width = 6,height = 8)
ggplot(df_sex_BMI,aes(x=factor(f.31.0.0),y=f.21001.0.0))
  +geom_boxplot(aes(fill=factor(f.31.0.0,levels = c("0", "1"),labels = c("Female","Male"))))
  +theme_bw()
  +theme(panel.background = element_blank(),panel.grid.major = element_blank(),panel.grid.minor = element_blank(),legend.position=c(0.88,0.85), legend.title=element_blank())
  +scale_x_discrete(limits=c("0","1"), labels=c( "Female","Male"))
  +xlab("Sex") 
  +ylab("BMI")
  +stat_summary(fun.y = "mean",geom="point",fill="white",shape=21,size=4)
  +labs(title="Interaction between Sex and BMI")
dev.off()

