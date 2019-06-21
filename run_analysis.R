library(data.table)
library(dplyr)

path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")


activitylabels <- read.csv("UCI HAR Dataset/activity_labels.txt",sep = " ", header=FALSE)
colnames(activitylabels) <- c("activity_number","activity")

features <- read.csv("UCI HAR Dataset/features.txt",sep = " ", header=FALSE)
colnames(features) <- c("feature_number","feature")

# select indices of columns we want, containing mean or std
featureswanted <- grep("(mean|std)\\(\\)", features$feature)

# select names of features wanted
featurenames <- features[featuresWanted,]
featurenames <- as.character(featurenames$feature)

# remove parentheses
cleanfeaturenames <- gsub('[()]', '', featurenames)

# load trainset, activity- and subjectnumber into one dataframe
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))
train <- train[,featureswanted,with=FALSE]
colnames(train) <- cleanfeaturenames
activities <- fread(file.path(path, "UCI HAR Dataset/train/y_train.txt"))
colnames(activities) <- c("activity")
subjectnumbers <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"))
colnames(subjectnumbers) = c("subjectnumber")
train <- cbind(subjectnumbers, activities, train)

# load testset, activity- and subjectnumber into another dataframe
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))
test <- test[,featureswanted,with=FALSE]
colnames(test) <- cleanfeaturenames
activities <- fread(file.path(path, "UCI HAR Dataset/test/y_test.txt"))
colnames(activities) <- c("activity")
subjectnumbers <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"))
colnames(subjectnumbers) = c("subjectnumber")
test <- cbind(subjectnumbers, activities, test)

# combine both dataframes 
total <- rbind(train, test)

# replace activity number by activity name
total[["activity"]] <- factor(total[, activity]
                                 , levels = activitylabels[["activity_number"]]
                                 , labels = activitylabels[["activity"]])

total[["subjectnumber"]] <- as.factor(total[, subjectnumber])

# write tidy data to file
data.table::fwrite(x = total, file = "total.csv", quote = FALSE)

library(reshape2)

# create a long dataframa with one row for each combination of subjectnumber+activity
averages <- reshape2::melt(data = total, id = c("subjectnumber", "activity"))
# compute mean for each combination of subjectnumber+activity
averages <- reshape2::dcast(data = averages, subjectnumber + activity ~ variable, fun.aggregate = mean)

# write averages to file
data.table::fwrite(x = averages, file = "averages.csv", quote = FALSE)


