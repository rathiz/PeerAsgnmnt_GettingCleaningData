### Peer Assignment for Getting and Cleaning Data

### We assume that the following files will be in the same directory

### run_analysis.R (This file)
###	activity_labels.txt
###	features.txt
###	X_test.txt
###	y_test.txt
###	subject_test.txt
###	X_train.txt
###	y_train.txt
###	subject_train.txt

## we will be using the above files to create the datasets as per the assignment.
## and the script has not much error checking!!!!

############ START

library(data.table)
library(reshape2)
library(plyr)

dfActivity = read.table("activity_labels.txt", stringsAsFactor=FALSE)
colnames(dfActivity) = c("activityCd", "activity")

t_activity = data.table(dfActivity, key="activityCd")

## we will use features.txt file to name the columns in subject_*.txt file
### and transform some of the special patterns so that the data dictionary 
### becomes the base for column names, the following transformation is performed

### yank ()  and ) with ""
### replace , - and ( with .

### and create a vector having .std. or .mean. for the study

dfCols = read.table("features.txt", stringsAsFactor=FALSE)
colnames(dfCols) = c("ColNo", "colName")

dfCols$colName = gsub("\\()|)", "", dfCols$colName)
dfCols$colName = gsub("[(,-]", ".", dfCols$colName)

colsToKeep = dfCols$colName[grep("\\.(mean|std)\\.", dfCols$colName)]

dfData = NULL
for (domain in c("train", "test")) {
	### since the txt files don't have any headers, read.table assigns V1 as first column name
	### and we use that name as we need to extract the vector from the data frame
	vSubject = read.table(paste("subject_", domain, ".txt", sep=""), stringsAsFactor=F)$V1
	vActivity = read.table(paste("y_", domain, ".txt", sep=""), stringsAsFactor=F)$V1

	### can't use fread from data.table as there is extra space in the beginning
	### of each line and fread croaks on it
	dfX0 = read.table(paste("X_", domain, ".txt", sep=""), stringsAsFactor=F)
	colnames(dfX0) = dfCols$colName		### name the 561 columns of the X*.txt file

	dfX = cbind(subject=vSubject, activityCd=vActivity, activity="", dfX0[,colsToKeep])
	dfData = if (is.null(dfData)){
		dfX
	} else {
		rbind(dfData, dfX)
	}
	cat(domain, ": done processing, total rows processed so far",  nrow(dfData), "\n")
}

### replace activityCd column with the descriptive label from dfActivity
### using data table for this purpose

### in dfData, convert activity (placeholder column) to character, 
### convert it to data table, get the activity label populated
### and convert the data table back to data frame, delete the activityCd column

dfData$activity = as.character(dfData$activity)
t_df = data.table(dfData, key="activityCd")
t_df[t_activity, activity := i.activity, nomatch=NA]
dfData = data.frame(t_df)
dfData$activityCd = NULL

### the following objects can be removed from workspace if needed
rm("colsToKeep", "dfCols", "dfX", "dfX0", "domain", "vActivity", "vSubject")

### convert the wide format data to molten data
m1 = melt(dfData, id=c("subject", "activity"), value.name = "measurement")
m1$variable = as.character(m1$variable)

### get the average of measurement for each variable,  change the variable name to reflect 
### that it has average of all the measurements for the relevant rows
### then write the tidy data set to a file

tidyData_long = ddply(m1, .(subject, activity, variable), summarise, avgMeasurement=mean(measurement, na.rm=T))
tidyData_long$variable = paste("avg_", tidyData_long$variable, sep="")
write.table(tidyData_long, "tidyDataset_long.txt", row.names=F)

### convert the long dataset to wide dataset and write it to the file
tidyData_wide = dcast(tidyData_long, subject + activity ~ variable)
write.table(tidyData_wide, "tidyDataset_wide.txt", row.names=F)
