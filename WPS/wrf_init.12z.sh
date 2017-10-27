#!/bin/bash

# Initialize WRF forecast
# 
# NOTE: must have already run geogrid

# Booleans: run = 1, don't = 0
ungrib=1
metgrid=1

#check for date (manual run)
if [ -z $1 ]
then
  echo "Syntax is $0 YYYYMMDD"
  exit
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

if [ $ungrib == 1 ]
then
  echo "Running ungrib"
  # rm log file, previous namelist, and previous processing
  \rm -f ungrib.log
  \rm -f namelist.wps
  \rm -f GRIBFILE*
  \rm -f FILE*

  # link to NAM files
  if [ -d ../DATA/nam/212_12z/$today ] 
  then
    echo "Linking NAM" 
    ./link_grib.csh ../DATA/nam/212_12z/$today/nam.t12z*.tm00.grib2
    #./link_grib.csh /home/data/nam/212/$today/*
  else 
    echo "NAM data does not exist for $today"
    echo "Aborting run..."
    kill -SIGINT $$
  fi

  # change dates in namelist.wps
  cat namelist.wps.start > namelist.wps
  # start_date = '2009-01-28_00:00:00','2009-01-28_00:00:00', '2009-01-28_00:00:00',
  startdate="${yr_s}-${mo_s}-${dy_s}_12:00:00"
  echo "start: $startdate"
  echo " start_date = '${startdate}','${startdate}','${startdate}','${startdate}'," >> namelist.wps
  # end_date   = '2009-01-30_00:00:00','2009-01-30_00:00:00', '2009-01-30_00:00:00',
  enddate="${yr_e}-${mo_e}-${dy_e}_12:00:00"
  echo "  end: $enddate"
  echo " end_date   = '${enddate}','${enddate}','${enddate}','${enddate}'," >> namelist.wps
  cat namelist.wps.end >> namelist.wps

  # run ungrib.exe
  ./ungrib.exe > ungrib.log 2>&1 

  echo 'ungrib completed'
fi

if [ $metgrid == 1 ]
then
  # rm log file and previous processing files
  \rm -f metgrid.log*
  \rm -f PFILE*

  # run metgrid.exe
  ./metgrid.exe > metgrid.log 2>&1 

  # rm old met file from run directory
  \rm -f ../WRFV3/run/met_em.d0*.nc

  # mv new files to run directory
  mv met_em.d0*.nc ../WRFV3/run
  
  echo 'metgrid completed'
fi

echo 'WPS completed'
