#!/bin/bash
#
# Run real.exe and wrf.exe

real=1
wrfe=1

#number of nodes to run on
nodes=10
#nodes=30

#check for date (manual run)
if [ -z $1 ]
then
  echo "Syntax is $0 YYYYMMDD"
  exit
else
  syr=`date -d $1 +%Y`
  smo=`date -d $1 +%m`
  sdy=`date -d $1 +%d`
  eyr=`date --date="$1 + 2 days" +%Y`
  emo=`date --date="$1 + 2 days" +%m`
  edy=`date --date="$1 + 2 days" +%d`
fi
dirname=`echo "$syr$smo$sdy"`
echo "Start = $syr$smo$sdy ; End = $eyr$emo$edy"

if [ $real == 1 ]
then

#change date in namelist.input
cat namelist.input.start > namelist.input
# start_year                          = 2009, 2009, 2009,
# start_month                         = 01,   01,   01,
# start_day                           = 28,   28,   28,
# start_hour                          = 00,   00,   00,
# start_minute                        = 00,   00,   00,
# start_second                        = 00,   00,   00,
# end_year                            = 2009, 2009, 2009,
# end_month                           = 01,   01,   01,
# end_day                             = 30,   30,   30,
echo " start_year = $syr, $syr, $syr, $syr," >> namelist.input
echo " start_month = $smo, $smo, $smo, $smo," >> namelist.input
echo " start_day = $sdy, $sdy, $sdy, $sdy," >> namelist.input
echo " start_hour = 12, 12, 12, 12," >> namelist.input
echo " start_minute = 00, 00, 00, 00," >> namelist.input
echo " start_second = 00, 00, 00, 00," >> namelist.input
echo " end_year = $eyr, $eyr, $eyr, $eyr," >> namelist.input
echo " end_month = $emo, $emo, $emo, $emo," >> namelist.input
echo " end_day = $edy, $edy, $edy, $edy," >> namelist.input
echo " start_hour = 12, 12, 12, 12," >> namelist.input
echo " start_minute = 00, 00, 00, 00," >> namelist.input
echo " start_second = 00, 00, 00, 00," >> namelist.input

cat namelist.input.end >> namelist.input

# delete rsl files
\rm -f rsl*
\rm -f real.log

# run real.ex
$BASE_DIR/WRFV3/run/real.exe > real.log 2>&1 < /dev/null

# create output directory
if [ -d $BASE_DIR/DATA/wrfout/$dirname ]
then
  echo "Directory $dirname already exists."
else
  mkdir $BASE_DIR/DATA/wrfout/$dirname
fi

# cp rsl.*.0000 to run save directory
\cp -f rsl.*.0000 $BASE_DIR/DATA/wrfout/$dirname

echo 'real.exe completed'
fi

if [ $wrfe == 1 ]
then
# rm rsl files, log
\rm -f rsl.*
\rm -f wrf.log

# run wrf.exe
/usr/local/bin/mpirun -np 6 ./wrf.exe > wrf.log 2>&1 </dev/null 

# cp output to save directory
\cp -f rsl.*.0000 $BASE_DIR/DATA/wrfout/$dirname
\cp -f namelist.input $BASE_DIR/DATA/wrfout/$dirname
\cp -f wrfout_d0* $BASE_DIR/DATA/wrfout/$dirname 
\cp -f wrfout_d01* $BASE_DIR/VISUALIZATION/wrfout_d01.nc
\cp -f wrfout_d02* $BASE_DIR/VISUALIZATION/wrfout_d02.nc
\rm -f wrfout_d0* 

#\cd /home/lsterzinger/Documents/wrfoutput/
#\rm -f wrfout*
#\cp $BASE_DIR/DATA/wrfout/$dirname/* ./
echo 'wrf.exe completed'
fi
