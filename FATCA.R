setwd("C:/Users/cberthillon/020.CharlesBerthillon.com/000.FATCA")
dataset<-"C:/Users/cberthillon/020.CharlesBerthillon.com/000.FATCA/FFIListFull.csv"
mydata <- read.csv2(dataset,header=T,sep=",")
if(!require(data.table)){install.packages("data.table")}
library("stringr")
library("plyr")
library("qcc")
library("ggplot2")
####################################################################################################
#GIIN:splitting GIIN with stringr package
#split GIIN example: "AAAUG3.99999.SL.764"
GIIN1<- str_sub(mydata$GIIN, 1, 6)
GIIN2<- str_sub(mydata$GIIN, 8, 12)
GIIN3<- str_sub(mydata$GIIN, 14, 15)
GIIN4<- str_sub(mydata$GIIN, 17, 19)

#Add new columns from GIIN1, GIIN2, GIIN3, GIIN4
mydata1<-cbind(GIIN1,GIIN2,GIIN3,GIIN4,mydata)

####################################################################################################
#Frequency analysis of GIIN3
#GIIN:counting freq GIIN with plyr package
df0<-count(mydata1$GIIN3)


##Converting from a contingency table of case
df1<-data.frame(df0)
df2<-df1[with(df1,order(freq,decreasing=TRUE)),] #df2 Sort by "freq" column:

####################################################################################################
## set the bar plot graph
#bar plot: with ggplot (?xxx) package
barplot(df2$freq, names.arg=df2$x, col="red", xlab="Category Code", ylab="Number of GIIN")
#bar plot matrix: with ggplot (?xxx) package
barplot(as.matrix(df2$freq, names.arg=df2$x))

png("df2.png", width=900, height=480, units="px")
barplot(df2$freq, names.arg=df2$freq, col="red", xlab="Category Code", ylab="Number of GIIN")
dev.off()

####################################################################################################

##CountryNm:Frequency analysis of CountryNm
CountCountryNm<-count(mydata1$CountryNm)
View(CountCountryNm)

##CountryNm:Converting from a contingency table of case
df3<-data.frame(CountCountryNm)
df3
View(df3)
df4<-df3[with(df3, order(freq,decreasing=TRUE)),] #df4 Sort by "freq" column:
df4
View(df4)

## set the bar plot graph
png("df4.png", width=900, height=480, units="px")
## set the levels in order we want
ggplot(df4, aes(x = df4$x, y = df4$freq)) +
        geom_bar(colour="black", fill="red", width=.7, stat="identity") +
        guides(fill=FALSE)+ #used for legend (tbc)
        geom_text(aes(label = sprintf("%.2f%%", df4$freq/sum(df4$freq) * 100)), vjust = -.5)+
        geom_text(aes(label = sprintf("%.2f%%",counts), size = 8, hjust = 0.5, vjust = 3))+
        
        xlab("Category") + 
        ylab("number of records") +
        ggtitle("Financial Institution or Branch category")


dev.off()

####################################################################################################

#CountryNm:Grouping records with low values and creating new table
df5<-subset(df4, subset=(freq<=100))
df6<-sum(df5$freq)
countries <- c("other")

df7 <- data.frame(
        countries = countries,
        records = df6,
        stringsAsFactors=FALSE
)
df8<-subset(df4, subset=(freq>100))
df9 <- data.frame(
        countries = df8$x,
        records = df8$freq,
        stringsAsFactors=FALSE
)
df10<-rbind(df7,df9)
df11<-df10[with(df10, order(records,decreasing=TRUE)),] # Sort by "records" column:

View(df11)

####################################################################################################
#CountryNm:Creating Pareto chart with package qcc "quality control charts" based on df11
pareto.chart(df11$records, ylab = "Financial Institution or Branch category",xlab=df11$countries, col=heat.colors(length(df11$records)))
df12<-pareto.chart(df11$records, ylab = "Financial Institution or Branch category",xlab=df11$countries)
df13<-cbind(df11,df12)
View(df13)

png("df14.png", width=900, height=480, units="px")
df14<-pareto.chart(df11$records, ylab = "Financial Institution or Branch category", xlab=df11$countries,col=heat.colors(length(df11$records)))
dev.off()
