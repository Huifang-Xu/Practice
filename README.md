# Practice to extract specific phenotype from UKB data 
#Practice: UKB phenotype data processing

#ICD-10: Data-Field 41270

#Sex: Data-Field 31

#Disease type: Chronic hepatitis, unspecified (code: K739)

### Bash: grep ICD-10 (Data-Field 41270) and Sex (Data-Field 31) information
head -n 1 ukb34137.tab | awk '{for(i=0;++i<=NF;)a[i]=a[i]?a[i] FS $i:$i}END{for(i=0;i++<NF;)print a[i]}' |le #select columns Sample ($1), Sex ($2), ICD-10 ($2926~$3138)

awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$2926,$2927,$2928,$2929,$2930,$2931,$2932,$2933,$2934,$2935,$2936,$2937,$2938,$2939,$2940,$2941,$2942,$2943,$2944,$2945,$2946,$2947,$2948,$2949,$2950,$2951,$2952,$2953,$2954,$2955,$2956,$2957,$2958,$2959,$2960,$2961,$2962,$2963,$2964,$2965,$2966,$2967,$2968,$2969,$2970,$2971,$2972,$2973,$2974,$2975,$2976,$2977,$2978,$2979,$2980,$2981,$2982,$2983,$2984,$2985,$2986,$2987,$2988,$2989,$2990,$2991,$2992,$2993,$2994,$2995,$2996,$2997,$2998,$2999,$3000,$3001,$3002,$3003,$3004,$3005,$3006,$3007,$3008,$3009,$3010,$3011,$3012,$3013,$3014,$3015,$3016,$3017,$3018,$3019,$3020,$3021,$3022,$3023,$3024,$3025,$3026,$3027,$3028,$3029,$3030,$3031,$3032,$3033,$3034,$3035,$3036,$3037,$3038,$3039,$3040,$3041,$3042,$3043,$3044,$3045,$3046,$3047,$3048,$3049,$3050,$3051,$3052,$3053,$3054,$3055,$3056,$3057,$3058,$3059,$3060,$3061,$3062,$3063,$3064,$3065,$3066,$3067,$3068,$3069,$3070,$3071,$3072,$3073,$3074,$3075,$3076,$3077,$3078,$3079,$3080,$3081,$3082,$3083,$3084,$3085,$3086,$3087,$3088,$3089,$3090,$3091,$3092,$3093,$3094,$3095,$3096,$3097,$3098,$3099,$3100,$3101,$3102,$3103,$3104,$3105,$3106,$3107,$3108,$3109,$3110,$3111,$3112,$3113,$3114,$3115,$3116,$3117,$3118,$3119,$3120,$3121,$3122,$3123,$3124,$3125,$3126,$3127,$3128,$3129,$3130,$3131,$3132,$3133,$3134,$3135,$3136,$3137,$3138}' ukb34137.tab > ukb34137_icd10_sex.tab

#awk 'BEGIN{FS=OFS="\t"}{icd=1;sex=1;for(i=1;i<=5172;i++){if($i~/f.41270.0./)icd=i;if($i=="f.31.0.0")sex=i};print $1,$icd,$sex}' ukb34137.tab > test_icd10_sex.tab

### R: processing ICD-10 and Sex information
interact -c 4 --mem=100G

ml R/4.0.0-foss-2019b

library(tidyverse)

df_all <- read.table("ukb34137.tab",header=TRUE, sep="\t")

df_split <- read.table("ukb34137_icd10_sex.tab",header=TRUE, sep="\t")

manyColsToDummy("K739",df_split[,3:215],"sum_icd10_table")

df_merge <- data.frame(df_split[,1:2],sum_icd10_table)

write.table(df_merge,file="ukb34137_icd10_K739_sex.txt",sep='\t',row.names = FALSE)

#library(ggplot2)

#ggplot(df_merge,aes(x=factor(K739),fill=factor(f.31.0.0,levels = c("0", "1"),labels = c("Female","Male"))))+geom_bar(position="dodge")+theme( legend.title=element_blank())

### Count sample number by sex and phenotype

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

### Barplot

library(plotrix)

pdf("UKB_ICD10K739_Sex2.pdf",height = 6,width = 8)

barpos<-barplot(newdata,names.arg=colnames(newdata),ylim=c(0,180),beside=TRUE,col=c("red","darkblue"),axes=FALSE,xlab = "Chronic hepatitis (K739)",legend.text = c("Female","Male"))

axis(2,at=c(0,20,40,60,80,100,120,140,160,180),labels=c(0,20,40,60,80,100,120,250000,300000,350000));

box()

axis.break(2,120,style="gap") #set break

text(barpos,newdata+10,c(female_K739_0,male_K739_0,female_K739_1,male_K739_1)) #add text on barplot

dev.off()

