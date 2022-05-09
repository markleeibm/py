dos2unix jobStreamAndDependency.csv
dos2unix scheduledetails.csv

#jobStreamAndDepdency.csv direct from OSD workbook
cat jobStreamAndDependency.csv | awk -F',' '{print $2,",",$4}' | sed '/ /s///g' | sed '/TWS_BATCH_NAME/s//JOBSTREAM/' | sed '/SUCCESSOR_TWS_BATCH_NAME/s//SUCCESSOR_JOBSTREAM/' >jsdepend.csv
if [ $# -eq 0 ]
then
project=ADP
else project=$1
fi
echo Deriving jobstream order for project $project.. please wait..
echo JOBSTREAM >uniqjs.csv
#scheduledetails.csv from OSD workbook
cat scheduledetails.csv | grep -v 'INI_FILE_NAME' | awk -F','  '{ if ($2 == "'$project'") print $7 }'   | sort | uniq >>uniqjs.csv
echo generated uniqjs.csv
python3 sched.py | tee orderedjs.csv #figure out the running order of jobstreams for the project
echo generated orderedjs.csv


