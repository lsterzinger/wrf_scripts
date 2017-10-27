#! /bin/bash
BASE_DIR=/home/lsterzinger/WRF
export NCARG_ROOT=/home/lsterzinger/NCL
export PATH=/home/lsterzinger/NCL/bin:$PATH

echo "Generating Plots"
cd $BASE_DIR/VISUALIZATION
rm ./*.png
ncl surface_d01.ncl
ncl surface_d02.ncl
rm *.nc

aws s3 rm s3://lsterzingerwrf/images/ --recursive
aws s3 sync ./ s3://lsterzingerwrf/images/ --acl public-read

