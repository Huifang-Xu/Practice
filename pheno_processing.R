#Practice: UKB phenotype data processing

#ICD-10: Data-Field 41270
#Sex: Data-Field 31
#Disease type: Chronic hepatitis, unspecified (code: K739)
#processing ICD-10 and Sex information

library(tidyverse)
#read data
df_split <- read.table("ukb34137_icd10_sex.tab",header=TRUE, sep="\t")

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
