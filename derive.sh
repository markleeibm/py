#!/bin/bash
# derive.sh = derive PMU TWS job run schedule
# Author: ML
# Version 1.0 Mon May  9 17:28:39 BST 2022 initial release
# Version 1.1 Wed May 11 18:36:09 BST 2022 updated to use JC JobStreamJobsOrdered.csv
#
# Usage derive.sh <dsprojectname> #one parameter
#
#requires FOUR csv files in the same directory which must be present:
# 1. jobStreamAndItsDepdendency.csv - from the LBG OSD spreadsheet, workbook of the same name
# 2. scheduleDetails.csv - from the LBG OSD spreadsheet, workbook of the same name (saved as csv format)
# 3. jobStreamJobsOrdered.csv - from Mike Boners TWS  Analysis spreadsheet of the same name (saved in csv format)
# 4. activeJobList.csv - from LBG OSD spreadsheet , activeJoblist workbook of the same name (saved as csv format)


echo derive.sh V1.1 
echo "Checking prereq csv files are present"

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

if ! [ -f jobStreamJobsOrdered.csv ]
then
    echo hobStreamJobsOrdered.csv not present in `pwd` - aborting
    exit 1
fi

if ! [ -f activeJobList.csv ]
then
    echo activeJobList.csv not present in `pwd` - aborting
    exit 1
fi

echo Generating PMU Schedule for requested project $project..
echo " "

echo Step 1... Deriving jobstream order for project $project.. this may take some time.. please wait..

dos2unix jobStreamAndItsDependency.csv
dos2unix scheduleDetails.csv

cat jobStreamAndItsDependency.csv | awk -F',' '{print $2,",",$4}' | sed '/ /s///g' | sed '/TWS_BATCH_NAME/s//JOBSTREAM/' | sed '/SUCCESSOR_TWS_BATCH_NAME/s//SUCCESSOR_JOBSTREAM/' >jsdepend.csv

echo JOBSTREAM >uniqjs.csv
cat scheduleDetails.csv | grep -v 'INI_FILE_NAME' | awk -F','  '{ if ($2 == "'$project'") print $7 }'   | sort | uniq >>uniqjs.csv
python3 sched.py > $project.orderedjs.csv #figure out the running order of jobstreams for the project
echo Step 1 Completed. Generated $project.orderedjs.csv ok
echo " "

echo Step 2.. Generating ordered jobs by ordered jobstream..
dos2unix jobStreamJobsOrdered.csv
dos2unix activeJobList.csv

export PATH=$PATH:$DSHOME/bin
cp $project.orderedjs.csv orderedjs.csv
outputFile=/opt/IBM/homes/dsadm/ml/tmp/py/Wavex.${project}_twsJobs
dsjob -run -wait -param pOutputFileName=$outputFile -param pProjectName=$project aaML genPmuSchedule
echo "Step 2 Completed, generated PMU schedule: $outputFile"
