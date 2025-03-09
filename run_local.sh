#!/usr/bin/env bash
set -e
PROPERTY_FILE=~/.aws/credentials

script_default='bestTraders.r'
script=${1:-$script_default}

echo "value: [$script]"

source ../get_property.sh

echo "# Reading secret access key from $PROPERTY_FILE"
SECRET_KEY=$(getProperty "aws_secret_access_key")

echo "Found secret key is $SECRET_KEY"
docker build -t mochi-r .


#symbols=( NZDUSD USDCAD USDCHF USDJPY XAUUSD )
symbols=(XAUUSD_BTM)
#symbols=( GBPUSD )

graph_types=( bestTraders.r stops.r years.r)


scenario="s_-100..-10..10___l_10..200..10___o_-100..-10..20___d_14..14..7___out_8..8..4"

#If use a filter specify it here.
#filter="_aggregationQueryTemplateMovingAverage"
filter=""

for symbol in "${symbols[@]}"
do

    for graph_type in "${graph_types[@]}"
    do

#	    echo "--------------- Executing $symbol $graph_type short ----------------------"
#
#
#        docker run -e AWS_ACCESS_KEY_ID=AKIAJPLUCUSY6N6ERQMA -e AWS_SECRET_ACCESS_KEY=${SECRET_KEY} mochi-r \
#            ${symbol}/${scenario}___short/aggregated-${symbol}_${scenario}___short${filter}-all.csv.lzo ${graph_type}


        echo "---------------- Executing $symbol $graph_type long ------------------------"

        docker run -e AWS_ACCESS_KEY_ID=AKIASQPLJ5PCTQ5WE25B -e AWS_SECRET_ACCESS_KEY=${SECRET_KEY} mochi-r \
            ${symbol}/${scenario}/aggregated-${symbol}_${scenario}${filter}_aggregationQueryTemplate-all.csv.lzo ${graph_type}


        docker rm -v $(docker ps -a -q -f status=exited)

    done
done
