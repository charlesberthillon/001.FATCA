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
f14<-as.Date(f13, "%Y-%m-%d")
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


f19<-dcast(f18, CountryNm ~ Extractdate, fun=sum)#YES!!! xxxxxxxxxxxxxxxxxxxxxxxxxxx
f20<-melt(f19)
colnames(f20)[3] <- "Extractdate"
colnames(f20)[4] <- "Frequence"
View(f19)
#GIIN: creation of the graph 
f21<-dcast(f18, GIIN ~ Extractdate)
f22<-melt(f21)
sum(f22$value)#to check if we still have tha adequate number of recors)
colnames(f22)[2] <- "Extractdate"
colnames(f22)[3] <- "Frequence"
f23<-ggplot(data=f22, aes(x=Extractdate, y=Frequence, fill=GIIN)) + geom_bar(stat="identity")
f23
View(f21)
#Country: creation of the graph 
f24<-melt(f16)
sum(f24$value)#to check if we still have tha adequate number of recors)
colnames(f24)[2] <- "Extractdate"
colnames(f24)[3] <- "Frequence"

f25<-f24[order(f24$Frequence,decreasing=TRUE), ]

f26 <- subset(f25, f25$Frequence>=1000)
f27<-ggplot(data=f26, aes(x=Extractdate, y=Frequence, fill=CountryNm)) + geom_bar(stat="identity")
f27


#R Manipulate#####################################"
require(manipulate)
manipulate(
        {
        f28 <- subset(f25, f25$Frequence>=f28)
        f29<-ggplot(data=f28, aes(x=Extractdate, y=Frequence, fill=CountryNm)) + geom_bar(stat="identity")
        f29
},
f28 = slider(1000, 10000, step=100, initial = 1000)
)

#R Manipulate bis#####################################"

manipulate(
{
        f30 <- subset(f25, f25$Frequence>=1000)
        f31 <- subset(f28, f28$Frequence>=f33)
        f32<-ggplot(data=f28, aes(x=Extractdate, y=Frequence, fill=CountryNm)) + 
                geom_bar(stat="identity")+
                facet_grid(Drug ~ Rep) + xlab("Expression Level") + ylab("Frequency")
        f32
},
f33 = picker("2014-07-01", "2014-08-01", "2014-09-01", "2014-10-01", "2014-11-01")
)

