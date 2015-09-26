# ===================================
# Getting and Cleaning Data
# ===================================

# Download the data file
webFile <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# Create a temp file
temp <- tempfile()
# Download the file to the temp file
download.file(webFile,temp, mode="wb")
# Unzip the file
unzip(temp)


# Load the data.table library
library(data.table)

# Load the dplyr library
library(dplyr)

# Load the test data
test.X_test <- read.table(file="test/X_test.txt")
test.subject <- read.table(file="test/subject_test.txt")
test.Y_test <- read.table(file="test/y_test.txt")

# Load the training data
train.X_train <- read.table(file="train/X_train.txt")
train.subject <- read.table(file="train/subject_train.txt")
train.Y_train <- read.table(file="train/y_train.txt")

# Load the activity labels
activity.labels <- read.table(file="activity_labels.txt")

# Load the features list
features <- read.table(file="features.txt")

# Merge the test and training data
all_data <- rbind(test.X_test, train.X_train)

# Merge the test and training subject data
all_subject <- rbind(test.subject, train.subject)

# Merge the test and training activity labels
all_activity <- rbind(test.Y_test, train.Y_train)

# Filter for features with Mean in the name
mean_cols <- grep("mean\\(\\)", features[,2])

# Filter for features with Mean in the name
std_cols <- grep("std\\(\\)", features[,2])

# Merge and sort the mean and std columns
all_cols <- sort(append(mean_cols, std_cols))

# Subset the data to include only the mean and std based columns
data <- all_data[,all_cols]

# Add column labels
names(data) <- as.character(features[all_cols,2])

# Combine the subsetted data with the subject and activy rows
data <- cbind(all_subject, all_activity, data)

# Rename the subject and activy columns to something that makes sense
colnames(data)[1] <- "Subject"
colnames(data)[2] <- "Activity"

# Replace the activity number with a matching label from the activity labels
for (ii in 1:dim(data[1])){
  x <- data[ii,2]
  y <- as.character(activity.labels$V2[activity.labels$V1==x])
  data[ii,2] <- y
}

# Convert to a dplyr object
data_dplyr <- tbl_df(data)

# Smmarise by Subject and Activity
summary_data <- data_dplyr %>% group_by(Subject, Activity) %>% summarise_each(funs(mean))
