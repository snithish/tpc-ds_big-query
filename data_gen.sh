# Generate test data on the large server
# You will need to have the tpcds dsdgen program built in the current directory

# Usage: ./data_gen.sh $CPU $SCALE

DATA_DIR=~/tpc-ds-data/scale-$2
gen() {
  CPU=$1
  SCALE=$2
  SEED=2019
  rm -rf $DATA_DIR
  mkdir $DATA_DIR
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