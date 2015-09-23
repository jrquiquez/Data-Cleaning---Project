##Step 1
#source of the data
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file <- "getdata_dataset.zip"

#downloads and stores data if it doesn't exists
if (!file.exists(file)){
  download.file(fileurl, file, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(file) 
}

##Step 2
#read the Activities data
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

#reads the features data 
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

##step 3
#select only mean and std
featuresData <- grep(".*mean.*|.*std.*", features[,2])
featuresNeeded <- features[featuresData,2]
featuresNeeded = gsub('-mean', 'Mean', featuresNeeded)
featuresNeeded = gsub('-std', 'Std', featuresNeeded)
featuresNeeded <- gsub('[-()]', '', featuresNeeded)

##step 4
#reads training group data
trainX <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresData]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train<-cbind(trainSubjects,trainActivities,trainX)

#reads tested group data
testX <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresData]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, testX)

#joins both data sets
tidyData<-rbind(test,train)
colnames(tidyData) <- c("subject","activity",featuresNeeded)

##step 5
#matches activities and change activity vector to name
tidyData$activity <- factor(tidyData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
tidyData$subject <- as.factor(tidyData$subject)

##step 6
#applies mean for every unique Activity, Subject
aggdata <- aggregate(x = tidyData[,3:79],by = list(Activity=tidyData$activity,Subject=tidyData$subject),FUN = mean, na.rm=T)

##step 7
#exports the data to a .txt file.
write.table(aggdata, "tidy.txt", row.names = FALSE, quote = FALSE)
