#!/bin/bash
# derive.sh = derive pmu schedule
# Author: ML
# Version 1.0 Mon May  9 17:28:39 BST 2022 initial release
#
# Usage derive.sh <dsprojectname> #one parameter
#
#requires THREE csv files in the same directory which must be present:
# 1. jobStreamAndItsDepdendency.csv - from the LBG OSD spreadsheet, workbook of the same name
# 2. scheduleDetails.csv - from the LBG OSD spreadsheet, workbook of the same name (saved as csv format)
# 3. Lloyds_DataStage_Job_Report_V1.1.csv - from Mike Boners TWS  Analysis spreadsheet of the same name (saved in csv format)


if [ $# -eq 0 ]
then
project=ADP
else project=$1
fi

echo Generating PMU Schedule for project $project..

dos2unix jobStreamAndItsDependency.csv
dos2unix scheduleDetails.csv

cat jobStreamAndItsDependency.csv | awk -F',' '{print $2,",",$4}' | sed '/ /s///g' | sed '/TWS_BATCH_NAME/s//JOBSTREAM/' | sed '/SUCCESSOR_TWS_BATCH_NAME/s//SUCCESSOR_JOBSTREAM/' >jsdepend.csv

echo Step 1... Deriving jobstream order for project.. this may take some time.. please wait..
echo JOBSTREAM >uniqjs.csv
#scheduledetails.csv from OSD workbook
cat scheduleDetails.csv | grep -v 'INI_FILE_NAME' | awk -F','  '{ if ($2 == "'$project'") print $7 }'   | sort | uniq >>uniqjs.csv
echo generated uniqjs.csv
python3 sched.py | tee orderedjs.csv #figure out the running order of jobstreams for the project
echo Step 1 Completed. Generated orderedjs.csv
echo " "

echo Step 2.. Generating ordered jobs by jobstream..
dos2unix Lloyds_DataStage_Job_Report_V1.1.csv
cat Lloyds_DataStage_Job_Report_V1.1.csv | awk -F','  '{ if ($3 == "RDWETLPRD") print $1,",",$2 }' |  sed '/ /s///g' >orderedjobsbyjs.csv

export PATH=$PATH:$DSHOME/bin
dsjob -run -wait aaML genPmuSchedule
echo Step 2 Completed /opt/IBM/homes/dsadm/ml/tmp/py/pmuschedule generated ok
