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

if ! [ -f jobStreamAndItsDependency.csv ]
then
    echo jobStreamAndItsDependency.csv not present in `pwd` - aborting
    exit 1
fi

if ! [ -f scheduleDetails.csv ]
then
    echo scheduleDetails.csv not present in `pwd` - aborting
    exit 1
fi

if ! [ -f Lloyds_DataStage_Job_Report_V1.1.csv ]
then
    echo Lloyds_DataStage_Job_Report_V1.1.csv not present in `pwd` - aborting
    exit 1
fi

echo derive.sh V1.0 
echo Generating PMU Schedule for requested project $project..
echo " "

echo Step 1... Deriving jobstream order for project $project.. this may take some time.. please wait..

dos2unix jobStreamAndItsDependency.csv
dos2unix scheduleDetails.csv

cat jobStreamAndItsDependency.csv | awk -F',' '{print $2,",",$4}' | sed '/ /s///g' | sed '/TWS_BATCH_NAME/s//JOBSTREAM/' | sed '/SUCCESSOR_TWS_BATCH_NAME/s//SUCCESSOR_JOBSTREAM/' >jsdepend.csv

echo JOBSTREAM >uniqjs.csv
cat scheduleDetails.csv | grep -v 'INI_FILE_NAME' | awk -F','  '{ if ($2 == "'$project'") print $7 }'   | sort | uniq >>uniqjs.csv
python3 sched.py > orderedjs.csv #figure out the running order of jobstreams for the project
echo Step 1 Completed. Generated orderedjs.csv ok
echo " "

echo Step 2.. Generating ordered jobs by ordered jobstream..
dos2unix Lloyds_DataStage_Job_Report_V1.1.csv
cat Lloyds_DataStage_Job_Report_V1.1.csv | awk -F','  '{ if ($3 == "RDWETLPRD") print $1,",",$2 }' |  sed '/ /s///g' >orderedjobsbyjs.csv

export PATH=$PATH:$DSHOME/bin
dsjob -run -wait aaML genPmuSchedule
outputFile=/opt/IBM/homes/dsadm/ml/tmp/py/Wavex.${project}_twsJobs
mv pmuschedule $outputFile
echo "Step 2 Completed, generated PMU schedule: $outputFile"
