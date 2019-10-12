# TPC - DS - Big Query


## Steps:

1. Move `dsdgen` to a GCS bucket
2. Create a new Bucket for storing generated data
3. Create a compute optimized `VM`
4. Pull `dsdgen` program
5. Set up GCS as a local storage to VM using Fuse [GCS Fuze integration](https://cloud.google.com/storage/docs/gcs-fuse)