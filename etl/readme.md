# ETL Documentation
Current ETL pipelines are implemented using Cloud Functions due to small source data file sizes and cost efficiency. Previously ETL pipelines were implemented using GCP Dataflow. However, this was deprecated due to high running costs with data updating only once a month.

## Currently used Cloud Functions
- `nn-kk-trigger-load-cs-to-bq` - Used when new file is loaded to determined Cloud Storage bucket. Adds metadata to certain columns and loads file contents to bigQuery staging table. [Documentation for the function](./nn-kk-trigger-load-cs-to-bq/readme.md)