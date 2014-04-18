PeerAsgnmnt_GettingCleaningData
===============================

Peer Assignment for Getting and Cleaning Data Course

Purpose of this assignment is to create a tidy data set from the
provided UCI HAR Dataset. We make the following assumptions:

The following data files will be in the same working directory where run_analysis.R will reside.

	activity_labels.txt
	features.txt
	test/X_test.txt
	test/y_test.txt
	test/subject_test.txt
	train/X_train.txt
	train/y_train.txt
	train/subject_train.txt

The script will create the tidy dataset in 2 formats.

	Wide Format: tidyDataset_wide.txt
	Long Format: tidyDataset_long.txt

For the assignment purpose, Wide Format tidy dataset (tidyDataset_wide.txt) is submitted.

activity_labels.txt file will be used to map activity code 1:6 to descriptive labels.

	dfActivity = read.table("activity_labels.txt", stringsAsFactor=FALSE)
	colnames(dfActivity) = c("activityCd", "activity")
	
	t_activity = data.table(dfActivity, key="activityCd")

Since the dataset files (both test and training) have no header info, we will use
features.txt file to name the columns in subject_*.txt files. To accomplish this we
need to transform some of the special patterns in the names so that the data dictionary 
becomes the base for column names, the following transformation is performed

* yank ()  and ) with ""
* replace , - and ( with .

And create a vector having .std. or .mean. patterns to extract data for the study

	dfCols = read.table("features.txt", stringsAsFactor=FALSE)
	colnames(dfCols) = c("ColNo", "colName")
	
	dfCols$colName = gsub("\\()|)", "", dfCols$colName)
	dfCols$colName = gsub("[(,-]", ".", dfCols$colName)
	
	colsToKeep = dfCols$colName[grep("\\.(mean|std)\\.", dfCols$colName)]

Since the test and train datafiles are organized neatly, we can iterate over them 
to create the final raw dataset having only mean and std columns.

we create subject vector from subject_*.txt file and activity vector from y_*.txt file

	vSubject = read.table(paste("subject_", domain, ".txt", sep=""), stringsAsFactor=F)$V1
	vActivity = read.table(paste("y_", domain, ".txt", sep=""), stringsAsFactor=F)$V1

Read the necessary X_* raw datafile using read.table. fread from data.table can't
be used as it errors out due to spaces in the beginning of lines.  After reading 
the datafile, we name all the 561 columns. From this data frame we extract the 
mean and std data items along with subjects, activity codes.  At this stage we 
also put a placeholder for the activity label. This gets us the final data frame 
by consolidating data from both test and training sets.

	dfX0 = read.table(paste("X_", domain, ".txt", sep=""), stringsAsFactor=F)
	colnames(dfX0) = dfCols$colName		### name the 561 columns of the X*.txt file

	dfX = cbind(subject=vSubject, activityCd=vActivity, activity="", dfX0[,colsToKeep])

we map activity code to descriptive label using data.table construct ':=' and delete
the activity code column.

	dfData$activity = as.character(dfData$activity)
	t_df = data.table(dfData, key="activityCd")
	t_df[t_activity, activity := i.activity, nomatch=NA]
	dfData = data.frame(t_df)
	dfData$activityCd = NULL

Tidy dataset requires computation of average of mean and std measures. Since the raw dataframe
is in wide format with multiple records for an attribute of a given subject and activity. 
To facilitate we use ddply/melt/dcast to do the computation.

We first convert the wide data frame to long format based on subject & activity as id and using melt 
This will create a long data frame of 4 columns; subject, activity, variable and its measurement.
The dataset has 48 mean and std variables.

	m1 = melt(dfData, id=c("subject", "activity"), value.name = "measurement")
	m1$variable = as.character(m1$variable)

Once the long data frame is created, ddply is used to compute mean of grouped rows based
on subject, activity, variable as grouping variable. Since resulting data frame has averaged
values, we tag the variable names by prefixing "avg_" to reflect the same.  The long format 
data frame is written to a file named "tidyDataset_long.txt".

	tidyData_long = ddply(m1, .(subject, activity, variable), summarise, 
						avgMeasurement=mean(measurement, na.rm=T))
	tidyData_long$variable = paste("avg_", tidyData_long$variable, sep="")
	write.table(tidyData_long, "tidyDataset_long.txt", row.names=F)

A Wide format of the dataset is also created using dcast on the tidy long format data frame. 
It is stored as "tidyDataset_wide.txt" file. Wide format data set is uploaded for the purpose 
of the assignment. A long format data file is also created and can be used, if needed.

	tidyData_wide = dcast(tidyData_long, subject + activity ~ variable)
	write.table(tidyData_wide, "tidyDataset_wide.txt", row.names=F)

