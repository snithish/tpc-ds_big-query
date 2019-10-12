#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


PROJECT=scale_$1

echo -e "${GREEN}Benchmarking Project: ${PROJECT}"

echo -e "${GREEN}Running Warmup Scripts - Starting"

# Warm-up
find warmup/ -name warmup_*.sql | sort -V | {
  while read line; do 
    echo "$line"
    cat "$line" | bq --dataset_id=${PROJECT} \
      query \
      --use_legacy_sql=false \
      --batch=false \
      --format=none
  done
}

echo -e "${GREEN}Running Warmup Scripts - Complete"

# Test
mkdir -p results
echo "Query,Started,Ended,Billing Tier,Bytes" > results/BigQueryResults.csv

echo -e "${GREEN}Running Benchmark Scripts - Starting"

find query/ -name query*.sql | sort -V | {
  while read -r f; do
    echo $f
    QUERY=`basename $f | head -c -5`
    ID=${QUERY}_$(date +%s)

    cat "$f" \
      | bq \
        --dataset_id=${PROJECT} \
        query \
        --use_legacy_sql=false \
        --batch=false \
        --maximum_billing_tier=10 \
        --job_id=$ID \
        --format=none

    JOB=$(bq --format=json show -j ${ID})

    echo $JOB >> results/${ID}-stat.json

    STARTED=$(echo $JOB | jq .statistics.startTime)
    ENDED=$(echo $JOB | jq .statistics.endTime)

    BILLING_TIER=$(echo $JOB | jq .statistics.query.billingTier)
    BYTES=$(echo $JOB | jq .statistics.query.totalBytesBilled)


    echo "$f,$STARTED,$ENDED,$BILLING_TIER,$BYTES" >> results/BigQueryResults.csv
  done
}

echo -e "${GREEN}Running Benchmark Scripts - Complete"