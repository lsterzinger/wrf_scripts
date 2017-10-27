#! /bin/bash
# Syncs with AWS s3 bucket
cd $BASE_DIR/DATA/wrfout/

aws s3 sync ./ s3://lsterzingerwrf/wrfout/
