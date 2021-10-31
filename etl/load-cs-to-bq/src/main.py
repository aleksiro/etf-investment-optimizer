from google.cloud import bigquery
import pandas as pd 
import time
from decimal import Decimal


def main(event, context):
    """Triggered by a change to a Cloud Storage bucket.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    print("INFO: Processing file:", event['name'])

  
    file_uri = "gs://" + event['bucket'] + '/' + event['name']
    print("INFO: File uri: " + file_uri)
    df = pd.read_csv(file_uri, encoding='utf-16', sep='\t')
    
    ticker = ''
    if event['name'].startswith('IUSN'):
        ticker = 'IUSN'
    elif event['name'].startswith('EUNL'):
        ticker = 'EUNL'
    elif event['name'].startswith('IS3N'):
        ticker = 'IS3N'
    else:
        ticker = 'ERROR'
    df['TICKER'] = ticker
    df['LOAD_TIMESTAMP'] = int(time.time())
    df['Date'] = df['Date'].astype(str)
    df['Close'] = df['Close'].round(2).astype(str).map(Decimal)
    df = df.rename(columns={"Date" : "DATE", 
                            "Close" : "CLOSE_PRICE", 
                            "Turnover volume" : "TURNOVER"})
    df = df[['LOAD_TIMESTAMP', 'TICKER', 'DATE', 'CLOSE_PRICE', 'TURNOVER']]
    print(df.head())

    client = bigquery.Client()
    
    table_id = 'nordnet-kk-saasto.stg.RAW_NORDNET_DATA'
    job_config = bigquery.LoadJobConfig(
        schema = [
            bigquery.SchemaField("LOAD_TIMESTAMP", "INTEGER"),
            bigquery.SchemaField("TICKER", "STRING"),
            bigquery.SchemaField("DATE", "STRING"),
            bigquery.SchemaField("CLOSE_PRICE", "NUMERIC", precision = 6, scale = 2),
            bigquery.SchemaField("TURNOVER", "INTEGER"),
        ],
    )

    load_job = client.load_table_from_dataframe(
        df, table_id, job_config=job_config
    )  # Make an API request.

    load_job.result()  # Waits for the job to complete.

    destination_table = client.get_table(table_id)  # Make an API request.
    print("Loaded", destination_table.num_rows, "rows to", table_id)
