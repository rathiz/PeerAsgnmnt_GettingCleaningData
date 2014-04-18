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

Since the dataset files (both test and training) have no header info, we will use
features.txt file to name the columns in subject_*.txt files. To accomplish this we
need to transform some of the special patterns in the names so that the data dictionary 
becomes the base for column names, the following transformation is performed

* yank ()  and ) with ""
* replace , - and ( with .

And create a vector having .std. or .mean. patterns to extract data for the study

Since the test and train datafiles are organized neatly, we can iterate over them 
to create the final raw dataset having only mean and std columns.

	we create subject vector from subject_*.txt file and activity vector from y_*.txt file

