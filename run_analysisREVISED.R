##Get Data: download and unzip file
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- File.path(getwd(), "Dataset.zip")
download.file(URL, f)
unzip("Dataset.zip")

##read files 
features <- read.table('./UCI HAR Dataset/features.txt')

activityLabels = read.table('./UCI HAR Dataset/activity_labels.txt')

##read training tables
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

##read test tables
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

##add descriptive labels
colnames(activityLabels) <- c("activityId", "activityLabel")
colnames(x_test) <- features[, 2]
colnames(x_train) <- features[, 2]
colnames(subject_test)<- "subject"
colnames(subject_train)<- "subject"
colnames(y_test)<- "activity"
colnames(y_train)<- "activity"


##merge training and test files
train <- cbind(subject_train, y_train, x_train)
test<- cbind(subject_test, y_test, x_test)
allactivitydata<- rbind(train, test)


##name the activities in the dataset
allactivitydata$activity <- factor(allactivitydata$activity, levels = activityLabels[,1],labels = activityLabels[, 2])


##Extract mean and Standard deviation
columnSubset <- grepl("subject|activity|mean|std", colnames(allactivitydata))
meanandstd <- allactivitydata[, columnSubset]

##clean variable names
variablenames <- colnames(meanandstd)
variablenames <- gsub("std", "standardDeviation", variablenames)
variablenames <- gsub("Acc", "accelorometer", variablenames)
variablenames <- gsub("Gyro", "gyroscope", variablenames)
variablenames <- gsub("BOdyBody", "Body", variablenames)
variablenames <- gsub("Freq", "frequency", variablenames)
variablenames <- gsub("^f", "frequencydomain", variablenames)
variablenames <- gsub("^t", "timedomain", variablenames)

##substitute the new column names in dataset
colnames(meanandstd) <- variablenames

##new tidy data set with the average of each variable for each activity and each subject
tidyDataMeans <- meanandstd %>%
  group_by(subject, activity) 
  tidydata <- summarize_all(tidyDataMeans, mean)

##Create new tidy dataset
write.table(tidydata, "tidy_data.txt", row.names = FALSE, quote = FALSE)
write.csv(tidydata, "tidydata.csv")
