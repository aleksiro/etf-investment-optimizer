# nn-kk-trigger-load-cs-to-bq
 Used when new file is loaded to determined Cloud Storage bucket. Adds metadata to certain columns and loads file contents to bigQuery staging table.

## Trigger: 
Triggered based on nn_kk_raw bucket Event type Finalize/Create.

## Logic
1. Parses TICKER code to own column based on the file name received from the storage trigger.
2. dds LOAD_TIMESTAMP as current timestamp 
3. Rounds close price to two decimals
4. Initializes bigquery client
5. Loads file content and parsed metadata to predefined schema using pandas dataframe 