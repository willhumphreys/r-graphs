#!/usr/bin/env bash
set -e

# Use environment variables with defaults as fallback
S3_SOURCE_BUCKET=${SOURCE_BUCKET:-"mochi-trades-aggregated"}
S3_GRAPHS_BUCKET=${GRAPHS_BUCKET:-"mochi-graphs"}

find . -name \*.lzo -delete
find . -name \*.csv -delete
echo "Copy from S3 with ${1}"
dest="$(echo $1 | awk -F/ '{print $NF}')"
echo "Destination is ${dest}"
aws s3 cp s3://${S3_SOURCE_BUCKET}/$1 ${dest}
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
aws s3 sync results s3://${S3_GRAPHS_BUCKET}/$1