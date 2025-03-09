#!/usr/bin/env bash
set -e
find . -name \*.lzo -delete
find . -name \*.csv -delete
echo "Copy from S3 with ${1}"
dest="$(echo $1 | awk -F/ '{print $NF}')"
echo "Destination is ${dest}"
aws s3 cp s3://mochi-trades-aggregated/$1 ${dest}
echo "File copied from S3. Decompressing"
lzop -d ${dest}
file=$(basename "${dest}" .lzo)
echo "Submitting '$file' to R script"
mkdir -p results/data
echo "Execute " $2
Rscript $2 ${file} results
#Rscript stops.r ${file} results
#echo "Execute years.r"
#Rscript years.r ${file} results
#echo "Sync graphs to S3"
aws s3 sync results s3://mochi-graphs/$1