library(dplyr)
getwd()

file<- "getdata_projectfiles_UCI HAR Dataset/UCI HAR D"

if(!file.exists(file)){
  fileurl<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileurl, file, method="curl")
}

if (!file.exists("./Dataset/UCI HAR Dataset")) { 
  unzip(file) 
}


#importing data
x_test<- read.table("./Dataset/UCI HAR Dataset/test/X_test.txt")
y_test<- read.table("./Dataset/UCI HAR Dataset/test/y_test.txt")
x_train<- read.table("./Dataset/UCI HAR Dataset/train/X_train.txt")
y_train<- read.table("./Dataset/UCI HAR Dataset/train/y_train.txt")
subject_test<- read.table("./Dataset/UCI HAR Dataset/test/subject_test.txt")
subject_train<- read.table("./Dataset/UCI HAR Dataset/train/subject_train.txt")

features<- read.table("./Dataset/UCI HAR Dataset/features.txt")
activity<- read.table("./Dataset/UCI HAR Dataset/activity_labels.txt")

#changing names of columns
colnames(x_test) <- features[,2]
colnames(y_test) <- "activityID"
colnames(subject_test) <- "subjectID"

colnames(x_train) <- features[,2]
colnames(y_train) <- "activityID"
colnames(subject_train) <- "subjectID"

colnames(activity) <- c("activityID", "activityName")
colnames(features)<- c("featureID", "featureName")
#part1 : Merging the data

xdata<- rbind(x_train, x_test)
ydata<- rbind(y_train,y_test)
subject<- rbind(subject_train, subject_test)
mergedata<- cbind(subject, xdata, ydata)

#part2 : Extracting only measurements on mean and sd for each measurement.

colnames<- colnames(mergedata)
colnames
extractdata<- grep("mean\\(\\)|std\\(\\)", features$featureName, value = T)

extractdata<- union(c("subjectID", "activityID"), extractdata)

mergedata<- subset(mergedata, select = extractdata)


#Part3 :Use descriptive activity names to name activities in the data set

mergedata<- merge(activity, mergedata, by="activityID", all.x = T)


#Part4 :Appropriately label the data set with descriptive variable names. 

head(str(mergedata))

names(mergedata)<- gsub("std()", "SD", names(mergedata))
names(mergedata)<- gsub("mean()", "MEAN", names(mergedata))
names(mergedata)<- gsub("^t", "Time", names(mergedata))
names(mergedata)<- gsub("^f", "Frequency", names(mergedata))
names(mergedata)<- gsub("Acc","Acclerometer",names(mergedata))
names(mergedata)<- gsub("Gyro", "Gyroscope", names(mergedata))
names(mergedata)<- gsub("Mag", "Magnitude", names(mergedata))

head(str(mergedata))
names(mergedata) <- gsub("BodyBody", "Body", names(mergedata))
head(str(mergedata))


#part5 :create an independent tidy data set with the average of each variable

tidydata<- mergedata %>% group_by(subjectID, activityName) %>%
          summarise_all(funs(mean))

write.table(tidydata, "tidydata.txt", row.names = F)


