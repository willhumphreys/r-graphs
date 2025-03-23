#!/usr/bin/env bash
set -e

# Use environment variables with defaults as fallback
S3_MOCHI_AGGREGATION_BUCKET=${MOCHI_AGGREGATION_BUCKET:-"mochi-prod-aggregated-trades"}
S3_MOCHI_GRAPHS_BUCKET=${MOCHI_GRAPHS_BUCKET:-"mochi-prod-summary-graphs"}

find . -name \*.lzo -delete
find . -name \*.csv -delete
echo "Copy from S3 with ${1}"
dest="$(echo $1 | awk -F/ '{print $NF}')"
echo "Destination is ${dest}"
aws s3 cp s3://${S3_MOCHI_AGGREGATION_BUCKET}/$1 ${dest}
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
aws s3 sync results s3://${S3_MOCHI_GRAPHS_BUCKET}/$1