#!/bin/bash


# get current working directory
MY_CWD=$(pwd)

# create a tmp directory
mkdir -p ./tmp


# download the data
if [ ! -f "./tmp/medicare_data.zip" ]; then
  echo "Downloading data file";
  wget -O ./tmp/medicare_data.zip "https://data.medicare.gov/views/bg9k-emty/files/Nqcy71p9Ss2RSBWDmP77H1DQXcyacr2khotGbDHHW_s?content_type=application%2Fzip%3B%20charset%3Dbinary&filename=Hospital_Revised_Flatfiles.zip"
else
  echo "Data file exists, not downloading";
fi

# unzip the data
unzip -d ./tmp ./tmp/medicare_data.zip



# tail files to remove first linewidth
OLD_HOSPITAL="./tmp/Hospital General Information.csv"
NEW_HOSPITAL="./tmp/hospitals.csv"

OLD_EFFECITVE="./tmp/Timely and Effective Care - Hospital.csv"
NEW_EFFECTIVE="./tmp/effective_care.csv"

OLD_READMIT="./tmp/Readmissions and Deaths - Hospital.csv"
NEW_READMIT="./tmp/readmissions.csv"

OLD_MEASURE="./tmp/Measure Dates.csv"
NEW_MEASURE="./tmp/Measures.csv"

OLD_SURVEY="./tmp/hvbp_hcahps_05_28_2015.csv"
NEW_SURVEY="./tmp/surveys_responses.csv"

tail -n +2 "$OLD_HOSPITAL" > $NEW_HOSPITAL
tail -n +2 "$OLD_EFFECITVE" > $NEW_EFFECTIVE
tail -n +2 "$OLD_READMIT" > $NEW_READMIT
tail -n +2 "$OLD_MEASURE" > $NEW_MEASURE
tail -n +2 "$OLD_SURVEY" > $NEW_SURVEY

head -n 2 "$OLD_HOSPITAL" > "./tmp/hospitals_sample.csv"
head -n 2 "$OLD_EFFECITVE" > "./tmp/effective_care_sample.csv"
head -n 2 "$OLD_READMIT" > "./tmp/readmissions_sample.csv"
head -n 2 "$OLD_MEASURE" > "./tmp/Measures_sample.csv"
head -n 2 "$OLD_SURVEY" > "./tmp/surveys_responses_sample.csv"



## make sure directory doesn't exist
hdfs dfs -rm -r -r /user/w205/hospital_compare

## first create directory
hdfs dfs -mkdir -p /user/w205/hospital_compare

hdfs dfs -mkdir -p /user/w205/hospital_compare/hospitals
hdfs dfs -put $NEW_HOSPITAL /user/w205/hospital_compare/hospitals

hdfs dfs -mkdir -p /user/w205/hospital_compare/effective_care
hdfs dfs -put $NEW_EFFECTIVE /user/w205/hospital_compare/effective_care

hdfs dfs -mkdir -p /user/w205/hospital_compare/readmissions
hdfs dfs -put $NEW_READMIT /user/w205/hospital_compare/readmissions

hdfs dfs -mkdir -p /user/w205/hospital_compare/measures
hdfs dfs -put $NEW_MEASURE /user/w205/hospital_compare/measures

hdfs dfs -mkdir -p /user/w205/hospital_compare/surveys
hdfs dfs -put $NEW_SURVEY /user/w205/hospital_compare/surveys


##
echo "List of HDFS files"
hdfs dfs -ls -R /user/w205/hospital_compare

# clean-up
#rm -rf ./tmp

# change directory back to where we started
cd $MY_CDW

#clean exit
exit
