# Generate test data on the large server
# You will need to have the tpcds dsdgen program built in the current directory

# Usage: ./data_gen.sh $CPU $SCALE

gen() {
  CPU=$1
  SCALE=$2
  SEED=2019
  DATA_DIR=~/tpc-ds-data/scale-$2
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
