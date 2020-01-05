##load DPLYR library
library(dplyr)

#Checks if the directory "data" exists, if not creates it
if(!file.exists("./data")){dir.create("./data")}

#Defines the url of the source files
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

#Download the sources
download.file(zipUrl, destfile = "./data/UCI HAR Dataset.zip")

#Unzip the downloaded zip file
unzip(zipfile= "./data/UCI HAR Dataset.zip", exdir = "./data")


#Define the path where the files are stored
Data_folder <- file.path("./data/UCI HAR Dataset")


#Read the data files
features <- read.table(file.path(Data_folder,"features.txt"), col.names = c("n","functions"))
activities <- read.table(file.path(Data_folder,"activity_labels.txt"), col.names = c("code", "activity"))
subject_test <- read.table(file.path(Data_folder,"test","subject_test.txt"), col.names = "subject")
x_test <- read.table(file.path(Data_folder,"test","X_test.txt"), col.names = features$functions)
y_test <- read.table(file.path(Data_folder,"test","y_test.txt"), col.names = "code")
subject_train <- read.table(file.path(Data_folder,"train","subject_train.txt"), col.names = "subject")
x_train <- read.table(file.path(Data_folder,"train","X_train.txt"), col.names = features$functions)
y_train <- read.table(file.path(Data_folder,"train","y_train.txt"), col.names = "code")

#Merge the tables
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
Subject <- rbind(subject_train, subject_test)
Merged_Data <- cbind(Subject, Y, X)


#Subest names of features on mean and standard deviation

TidyData <- Merged_Data %>% select(subject, code, contains("mean"), contains("std"))

#label the data with descriptive variable names
TidyData$code <- activities[TidyData$code, 2]
names(TidyData)[2] = "activity"
names(TidyData)<-gsub("Acc", "Accelerometer", names(TidyData))
names(TidyData)<-gsub("Gyro", "Gyroscope", names(TidyData))
names(TidyData)<-gsub("BodyBody", "Body", names(TidyData))
names(TidyData)<-gsub("Mag", "Magnitude", names(TidyData))
names(TidyData)<-gsub("^t", "Time", names(TidyData))
names(TidyData)<-gsub("^f", "Frequency", names(TidyData))
names(TidyData)<-gsub("tBody", "TimeBody", names(TidyData))
names(TidyData)<-gsub("-mean()", "Mean", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-std()", "STD", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-freq()", "Frequency", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("angle", "Angle", names(TidyData))
names(TidyData)<-gsub("gravity", "Gravity", names(TidyData))

#Create a txt tidy data file with the average of each variable
FinalData <- TidyData %>%
        group_by(subject, activity) %>%
        summarise_all(funs(mean))
write.table(FinalData, file.path(Data_folder,"FinalData.txt"), row.name=FALSE)

