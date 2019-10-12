# Generate test data on the large server
# You will need to have the tpcds dsdgen program built in the current directory

# Usage: ./data_gen.sh $CPU $SCALE

PROJECT=scale_$2

GCS_BUCKET=data_$PROJECT
DATA_DIR=~/$GCS_BUCKET

# Delete existing data dir
rm -rf $DATA_DIR

# Create mount point
mkdir $DATA_DIR

# Remove existing bucket
gsutil rb -f gs://$GCS_BUCKET

# Create bucket
gsutil mb -c standard -l us-east1 gs://$GCS_BUCKET

# Mount GCS bucket to VM
gcsfuse $GCS_BUCKET $DATA_DIR

gen() {
  CPU=$1
  SCALE=$2
  SEED=2019
  seq 1 $CPU \
    | xargs -t -P$CPU -I__ \
        ./dsdgen \
          -SCALE $SCALE \
          -DELIMITER \| \
          -PARALLEL $CPU \
          -CHILD __ \
          -TERMINATE N \
          -RNGSEED $SEED \
          -DIR $DATA_DIR
}

gen $1 $2

# Rename to help with 'wildcard' loading
cd $DATA_DIR
for f in customer_[0-9]*_*; do mv $f prefix_fix_${f#file_[0-9]*_}; done
for f in store_[0-9]*_*; do mv $f prefix_fix_${f#file_[0-9]*_}; done