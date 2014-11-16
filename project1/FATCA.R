setwd("C:/Users/cberthillon/997.FATCA/project1")

#read function
f1 <- function(id, directory, summarize = FALSE) {
        f2 <- paste(getwd(),"/","001.data","/",sprintf("%08d", as.numeric(id)), ".csv", sep = "") #file sting function
        f3 <- read.csv(f2)
        if (summarize) {
                print(summary(f3))
        }
        return(f3)
}
data <- f1(20140701,'001.data', TRUE)

# =============================================================
#FATCA Compile files
require(plyr)
setwd("C:/Users/cberthillon/997.FATCA/project1")
f4<-'C:/Users/cberthillon/997.FATCA/project1/001.data'

f5 <- list.files(path = f4, pattern = NULL, all.files = FALSE, full.names = TRUE, recursive = FALSE, ignore.case = FALSE)
# Source: http://stackoverflow.com/questions/5186570/when-importing-csv-into-r-how-to-generate-column-with-name-of-the-csv
# list.files() function reads into R the names of every file in that directory
# f5= filenames
# f6=read_csv_filename

f6 <- function(f5){  #read_csv_file
        f7 <- read.csv(f5)
        f7$Source <- f5 #EDIT
        f7
}

f8 <-ldply(f5,f6) # import and concatenate the source.list


#================================================================

#Organize and clean data
require(stringr)
f9<-data.frame(f8)

#Column "Source": subset the file name and format it in date
f10<-str_sub(f9$Source, -12, -9)
f11<-str_sub(f9$Source, -8, -7)
f12<-str_sub(f9$Source, -6, -5)
f13<-cbind(f10,"-",f11,"-",f12)
f13<-paste (f10,f11,f12, sep = "-", collapse = NULL)
f14<-as.Date(f13)
f15<-cbind(f14,f9)
colnames(f15)[1] <- "Extractdate"
f15$Source<-NULL #delete column with source URL
### TO BE ANALYZED: f15$Extracdate <- strptime(f15$Extracdate, "%d/%m/%Y")# foramting date and time

#===========================================
# Step 1. create subsets of data by Financial institution or Branch category 
# Step 1.1: create a pivot table
# source: http://www.r-bloggers.com/pivot-tables-in-r/

require(reshape2)
require(data.table)
require(ggplot2)
#Overall check per country
f16<-dcast(f15, CountryNm ~ f14) #Pivot table ExtractDate per country
# dcast intersting URL: http://www.dummies.com/how-to/content/how-to-cast-data-to-wide-format-in-r.html

f17<-substr(f15$GIIN, 14, 15)
f18 <- cbind(f15, f17) # new column
colnames(f18)[2] <- "GIINx"
colnames(f18)[5] <- "GIIN"


f19<-dcast(f18, CountryNm+GIIN ~ Extractdate, fun=sum)#YES!!!
f20<-melt(f19)
colnames(f20)[3] <- "Extractdate"
colnames(f20)[4] <- "Frequence"

#GIIN: creation of the graph 
f21<-dcast(f18, GIIN ~ Extractdate)
f22<-melt(f21)
sum(f22$value)#to check if we still have tha adequate number of recors)
colnames(f22)[2] <- "Extractdate"
colnames(f22)[3] <- "Frequence"
f23<-ggplot(data=f22, aes(x=Extractdate, y=Frequence, fill=GIIN)) + geom_bar(stat="identity")
f23

#Country: creation of the graph 
f24<-melt(f16)
sum(f24$value)#to check if we still have tha adequate number of recors)
colnames(f24)[2] <- "Extractdate"
colnames(f24)[3] <- "Frequence"

View(f22)

f25<-f24[order(f24$Frequence,decreasing=TRUE), ]

f26 <- subset(f25, f25$Frequence>=4000)

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
p1<-ggplot(f26, aes(x=CountryNm, y=Frequence, fill=Extractdate, label="")) + 
        geom_bar(aes(stat="identity",weight=CountryNm, fill=Extractdate)) + 
        geom_text(hjust = 0, size = 3) + 
        coord_flip() +
        theme_minimal()
p1

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

#B-extract graph====================================================================
png("graph.png", width=480, height=480, units="px")
dev.off()
#E-extract graph====================================================================

#Define checks per GIIN
#START############################NOT USED#################################################
# 1. filter GIIN
fxx<-str_match(fx$GIIN, ".*\\.SL.*")[, 1]

fxx$GIIN<-NULL
fxx<-substr(f15$GIIN, 14, 15)
fxx$GIIN1 = paste(f16) #new column : concatenate abbreviated GIIN
fxx <- subset(f15 , GIIN1 = SL)
fyy<-fx[order(fx$september,decreasing=TRUE), ]
fyy <- subset(fx, fx$september>=1000)
#END############################NOT USED#################################################

#DATA REVIEW WORK============================================
#check unique value in columns
a<-unique(unlist(f15$Extractdate, use.names = FALSE))
b<-unique(unlist(f15$CountryNm, use.names = FALSE))
View(b)
