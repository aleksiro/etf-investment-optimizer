
resource "google_bigquery_dataset" "dw" {
    dataset_id    = "dw"
}
            
resource "google_bigquery_table" "ETF_DAILY_CLOSE" {
dataset_id = google_bigquery_dataset.dw.dataset_id
table_id   = "ETF_DAILY_CLOSE"
schema = file("../nordnet-kk-saasto/schemas/dw/tables/ETF_DAILY_CLOSE.json")
}
            
resource "google_bigquery_table" "REF_ETF_PARAMETERS" {
dataset_id = google_bigquery_dataset.dw.dataset_id
table_id   = "REF_ETF_PARAMETERS"
schema = file("../nordnet-kk-saasto/schemas/dw/tables/REF_ETF_PARAMETERS.json")
}
            
                resource "google_bigquery_table" "REF_ETF_PARAMETERS_CURRENT" {
                dataset_id = google_bigquery_dataset.dw.dataset_id
                table_id   = "REF_ETF_PARAMETERS_CURRENT"
                
                view {
                    query          = file("./schemas/dw/views/REF_ETF_PARAMETERS_CURRENT.sql")
                    use_legacy_sql = false
                    }
                }
            
resource "google_bigquery_table" "REF_ETF_PORTIONS" {
dataset_id = google_bigquery_dataset.dw.dataset_id
table_id   = "REF_ETF_PORTIONS"
schema = file("../nordnet-kk-saasto/schemas/dw/tables/REF_ETF_PORTIONS.json")
}
            
resource "google_bigquery_table" "REF_TICKERS" {
dataset_id = google_bigquery_dataset.dw.dataset_id
table_id   = "REF_TICKERS"
schema = file("../nordnet-kk-saasto/schemas/dw/tables/REF_TICKERS.json")
}
            