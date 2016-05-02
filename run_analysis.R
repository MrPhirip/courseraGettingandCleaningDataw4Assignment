#Get required packages
library(dplyr)

#setwd for local machine in casies 
#setwd("./R/Getting and Cleaning Data/Assignment")
#Set up folder structure and download data
      #UCI HAR Dataset
  if(!dir.exists("./data")){dir.create("./data")}
  if(!dir.exists("./data/UCI HAR Dataset")){
    dataURL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(dataURL,"./data/assignmentdataset.zip", method="libcurl")
    unzip("./data/assignmentdataset.zip", exdir="./data")
    logstring <- gsub(":","",paste0("./data/data obtained on ",date()))
    file.create(logstring)
}

#get data sets
  #use blank sep to check for whitespace, treats multiple whitespace characters as one
#Load Test and Train data sets
x_test<-read.csv(file="./data/UCI HAR Dataset/test/X_test.txt",header=FALSE,sep="")
x_train<-read.csv(file="./data/UCI HAR Dataset/train/X_train.txt",header=FALSE,sep="")
y_test<-read.csv(file="./data/UCI HAR Dataset/test/y_test.txt",header=FALSE,sep="")
y_train<-read.csv(file="./data/UCI HAR Dataset/train/y_train.txt",header=FALSE,sep="")

#load subject labels
x_test_subj<-read.csv(file="./data/UCI HAR Dataset/test/subject_test.txt",header=FALSE,sep="")
x_train_subj <-read.csv(file="./data/UCI HAR Dataset/train/subject_train.txt",header=FALSE,sep="")

#Append the data set seperately add subject columns in X binding
X<-rbind(cbind(x_train,x_train_subj),cbind(x_test,x_test_subj))
Y<-rbind(y_train,y_test)

#load header information
x_head <- read.csv(file="./data/UCI HAR Dataset/features.txt",header=F,sep="",stringsAsFactors=F)

#Add header information to data frames
names(Y) <- "activity"
names(X) <- c(x_head[,2],"subject") #include header for subject

#Filter data in X to only incldue meansurements on the mean and standard deviation(std)
X<-X[,grepl("mean\\(|std\\(|subject",names(X))]

#Append the Activity Field
fulldf <- cbind(X,Y)

#Load Detailed Activity Names
activity_labels <- read.csv(file="./data/UCI HAR Dataset/activity_labels.txt",header=F,sep="")
names(activity_labels) <- c("activity","detailedactivity")

#Join the activity labels into the data
HAR_dataset<-merge(x=fulldf,y=activity_labels,by="activity",all.x=T)

#convert HAR_dataset to a tbl
HAR_tbl <- tbl_df(HAR_dataset)

#Give HAR_tbl groupings
HAR_tbl <- group_by(HAR_tbl,detailedactivity,subject)

#Summarise R table by activity and each subject
HAR_tbl_summary <- summarise_each(HAR_tbl,funs(mean))
HAR_tbl_summary <- HAR_tbl_summary[,names(HAR_tbl_summary)!="activity"]
#Write result
if(!dir.exists("./output")){dir.create("./output")}
write.table(HAR_tbl_summary,file="./output/SamsungDataSummary.txt",row.name=F)
