#!/bin/bash
#
# run WRF forecast using 2.2
# if enter date from command line, that date will be used
# otherwise, uses today's date
#
# syntax: run_forecast.sh YYYYMMDD
#
# written: G. Mullendore, 03/2009
#   04/09: use NAM 212 instead of 218
#   11/09: switch to WRFv311
#   02/10: switch to defaulting to _tomorrow_ (00Z run starts at 9:45pm)
#          all scripts called from here get date passed to them
#   05/10: added copy to POLCAST directory
#   05/12: western ND edition (and running under "forecast" login)
#   2016/2017 modifications by Lucas Sterzinger
export BASE_DIR=/home/lsterzinger/WRF
export MP_STACK_SIZE 64000000

ulimit -s unlimited

cd $BASE_DIR
echo -n 'Started at '; date

wps=1
wrf=1
proc=0 #post_processing (for testing purposes)
sync=1
poweroff=0
visualize=1

#check for date (manual run)
if [ -z $1 ]
then
  today=`date --date="tomorrow" +%Y%m%d`
  yr_s=`date --date="tomorrow" +%Y`
  mo_s=`date --date="tomorrow" +%m`
  dy_s=`date --date="tomorrow" +%d`
  yr_e=`date --date='3 days' +%Y`
  mo_e=`date --date='3 days' +%m`
  dy_e=`date --date='3 days' +%d`
#  today=`date --date="today" +%Y%m%d`
#  yr_s=`date --date="today" +%Y`
#  mo_s=`date --date="today" +%m`
#  dy_s=`date --date="today" +%d`
#  yr_e=`date --date='2 days' +%Y`
#  mo_e=`date --date='2 days' +%m`
#  dy_e=`date --date='2 days' +%d`

elif [ $1 == "poweroff" ]
then
  poweroff=1
  echo "Will be powering off"
  today=`date --date="today" +%Y%m%d`
  yr_s=`date --date="today" +%Y`
  mo_s=`date --date="today" +%m`
  dy_s=`date --date="today" +%d`
  yr_e=`date --date='3 days' +%Y`
  mo_e=`date --date='3 days' +%m`
  dy_e=`date --date='3 days' +%d`

else
  echo "Input = $1"
  today=$1
  yr_s=`date --date=$1 +%Y`
  mo_s=`date --date=$1 +%m`
  dy_s=`date --date=$1 +%d`
  yr_e=`date --date="$1 + 2 days" +%Y`
  mo_e=`date --date="$1 + 2 days" +%m`
  dy_e=`date --date="$1 + 2 days" +%d`
fi
echo "Running with date $today"

# Delete old data
$BASE_DIR/DATA/clean_data.sh

if [ $wps == 1 ]
then
  echo 'Calling wrf_init'
  mkdir $BASE_DIR/DATA/nam/212/$today
  cd $BASE_DIR/DATA/nam/212/$today
  $BASE_DIR/DATA/nam/212/get00Z.sh $today >& $BASE_DIR/DATA/nam/212/get00Z.log
  cd $BASE_DIR

  cd WPS
  ./wrf_init.sh $today
  cd ..
fi

if [ $wrf == 1 ]
then
  echo 'Calling wrf_run'
  cd WRFV3/run
  ./wrf_run.sh $today
  cd ../..
fi

if [ $proc == 1 ]
then
  echo 'Calling wrf_post...'
  cd rip_proc
  ./wrf_proc.sh $today
  cd ..
#  cd /home/data/wrfout
#  ./mv_script.sh $today
fi

if [ $sync == 1 ]
then
 echo 'Syncing with AWS s3...'
 cd $BASE_DIR
 ./aws_sync.sh
fi

if [ $visualize == 1 ]
then
 echo 'Running Visualization'
 cd $BASE_DIR
 ./visualize.sh
fi 

echo 'Done'
echo -n 'Ended at '; date

if [ $poweroff == 1 ]
then
 echo 'Shutting down...'
 sudo poweroff
fi

