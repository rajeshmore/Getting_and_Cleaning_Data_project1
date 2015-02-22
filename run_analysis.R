#Here are the data for the project: 
#  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#You should create one R script called run_analysis.R that does the following. 
#Merges the training and the test sets to create one data set.
#Extracts only the measurements on the mean and standard deviation for each measurement. 
#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive variable names. 
#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

setwd("~/Documents/Coursera/cleaningdata/Project/UCI HAR Dataset")

require("data.table")

# Load data
activity_labels <- read.table("activity_labels.txt")[,2]
features <- read.table("features.txt")[,2]
X_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")
subject_test <- read.table("test/subject_test.txt")
X_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")
subject_train <- read.table("train/subject_train.txt")

# Extract only required data mean and std
extract_features <- grepl("mean|std", features)
names(X_test) = features
X_test = X_test[,extract_features]

# Define activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Merge dat set using cbind and define lable
data1 <- cbind(as.data.table(subject_test), y_test, X_test)
names(X_train) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,extract_features]

# Load activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Merge train data set  
data2 <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train data set
mydata = rbind(data1, data2)

# Define lables and merge -  melt function
id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
require("reshape2")
data3 = melt(mydata, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
final_data_set   = dcast(data3, subject + Activity_Label ~ variable, mean)

# Write output file
write.table(final_data_set, file = "final_data.txt",row.name=FALSE)

