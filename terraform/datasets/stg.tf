
resource "google_bigquery_dataset" "stg" {
    dataset_id    = "stg"
}
            
resource "google_bigquery_table" "RAW_NORDNET_DATA" {
dataset_id = google_bigquery_dataset.stg.dataset_id
table_id   = "RAW_NORDNET_DATA"
schema = file("../nordnet-kk-saasto/schemas/stg/tables/RAW_NORDNET_DATA.json")
}
            
resource "google_bigquery_table" "RAW_NORDNET_DATA_error_records" {
dataset_id = google_bigquery_dataset.stg.dataset_id
table_id   = "RAW_NORDNET_DATA_error_records"
schema = file("../nordnet-kk-saasto/schemas/stg/tables/RAW_NORDNET_DATA_error_records.json")
}
            
resource "google_bigquery_table" "RAW_YAHOO_TABLE" {
dataset_id = google_bigquery_dataset.stg.dataset_id
table_id   = "RAW_YAHOO_TABLE"
schema = file("../nordnet-kk-saasto/schemas/stg/tables/RAW_YAHOO_TABLE.json")
}
            
resource "google_bigquery_table" "RAW_YAHOO_TABLE_error_records" {
dataset_id = google_bigquery_dataset.stg.dataset_id
table_id   = "RAW_YAHOO_TABLE_error_records"
schema = file("../nordnet-kk-saasto/schemas/stg/tables/RAW_YAHOO_TABLE_error_records.json")
}
            