# TPC - DS - Big Query

**Credits:** Most scripts have been referenced from [Fivetran DW Benchmark](https://github.com/fivetran/benchmark) and have been adapted to suit our particular usecase.

## Steps:

1. Move `dsdgen` to a GCS bucket to a specific location as mentioned in the bootstrap script
2. Create a High CPU `VM` eg. _16vCPU_
3. Clone this repository
```sh
git clone $REPO_URL
```
4. Give all script files executable permission
```sh
chmod +x *.sh
```
4. Run `bootstrap.sh`
    1. This pulls `dsdgen` binary
    2. Installs [Google Fuse](https://github.com/GoogleCloudPlatform/gcsfuse/); this is to mount GCS bucket as a local folder - [More info](https://cloud.google.com/storage/docs/gcs-fuse)
5. Run `data_gen.sh` <br />
    **Usage:**
    ```sh
    ./data_gen.sh $CPU $SCALE
    ```
    1. This is responsible for generating data
    2. `$CPU` denotes the amount of parallelism must be > 1
    3. `$SCALE` denotes the scale of data that needs to be generated
    4. This creates and mounts a GCS Bucket and writes data to it
    5. **NOTE:** Ensure that `$CPU` is close to number of CPUs in VM for efficient parallel generation
6. Run `load_data.sh` <br />
    **Usage:**
    ```sh
    ./load_data.sh $SCALE
    ```
    1. This is responsible of loading data in GCP buckets created in step 5 to [BigQuery](https://cloud.google.com/bigquery/)
    2. `$SCALE` denotes the scale of data that needs to be loaded to BigQuery
    3. **Note:** Before running this step ensure that data is generated and present in the appropriate GCS Bucket
7. Run `benchmark.sh` <br />
    **Usage:**
    ```sh
    ./benchmark.sh $SCALE
    ```
   1. This is responsible for running TPC-DS queries and measuring query execution time
   2. Generates a `csv` file in `results` folder containing the query `start_time` and `end_time`
   3. Saves query statistics in the same directory
