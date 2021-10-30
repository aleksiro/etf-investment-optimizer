
resource "google_bigquery_dataset" "pub" {
    dataset_id    = "pub"
}
            
                resource "google_bigquery_table" "NN_KK_ETF_CALC_RES_PORTION_AND_SUMS" {
                dataset_id = google_bigquery_dataset.pub.dataset_id
                table_id   = "NN_KK_ETF_CALC_RES_PORTION_AND_SUMS"
                
                view {
                    query          = file("./schemas/pub/views/NN_KK_ETF_CALC_RES_PORTION_AND_SUMS.sql")
                    use_legacy_sql = false
                    }
                }
            
                resource "google_bigquery_table" "NN_KK_ETF_MULTIPLIERS" {
                dataset_id = google_bigquery_dataset.pub.dataset_id
                table_id   = "NN_KK_ETF_MULTIPLIERS"
                
                view {
                    query          = file("./schemas/pub/views/NN_KK_ETF_MULTIPLIERS.sql")
                    use_legacy_sql = false
                    }
                }
            
                resource "google_bigquery_table" "NN_KK_ETF_PERFORMANCE" {
                dataset_id = google_bigquery_dataset.pub.dataset_id
                table_id   = "NN_KK_ETF_PERFORMANCE"
                
                view {
                    query          = file("./schemas/pub/views/NN_KK_ETF_PERFORMANCE.sql")
                    use_legacy_sql = false
                    }
                }
            
                resource "google_bigquery_table" "NN_KK_LATEST_PRICE" {
                dataset_id = google_bigquery_dataset.pub.dataset_id
                table_id   = "NN_KK_LATEST_PRICE"
                
                view {
                    query          = file("./schemas/pub/views/NN_KK_LATEST_PRICE.sql")
                    use_legacy_sql = false
                    }
                }
            
                resource "google_bigquery_table" "NN_KK_MONTHLY_AVG_PRICES" {
                dataset_id = google_bigquery_dataset.pub.dataset_id
                table_id   = "NN_KK_MONTHLY_AVG_PRICES"
                
                view {
                    query          = file("./schemas/pub/views/NN_KK_MONTHLY_AVG_PRICES.sql")
                    use_legacy_sql = false
                    }
                }
            
                resource "google_bigquery_table" "NN_KK_MONTHLY_PRICES_WITH_TRENDS" {
                dataset_id = google_bigquery_dataset.pub.dataset_id
                table_id   = "NN_KK_MONTHLY_PRICES_WITH_TRENDS"
                
                view {
                    query          = file("./schemas/pub/views/NN_KK_MONTHLY_PRICES_WITH_TRENDS.sql")
                    use_legacy_sql = false
                    }
                }
            
                resource "google_bigquery_table" "NN_KK_TREND_LINE_VALUES" {
                dataset_id = google_bigquery_dataset.pub.dataset_id
                table_id   = "NN_KK_TREND_LINE_VALUES"
                
                view {
                    query          = file("./schemas/pub/views/NN_KK_TREND_LINE_VALUES.sql")
                    use_legacy_sql = false
                    }
                }
            