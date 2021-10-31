terraform {
  required_version = ">=0.12"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.90.0"
    }
  }
}

provider "google" {
  project = "etf-optimizer"
  region  = "europe-north1"
  zone    = "europe-north1-a"
}

resource "google_storage_bucket" "raw_data_bucket" {
  name          = "${var.project_name}-${var.environment}-cs-bucket-raw"
  location      = var.default_location
  project       = var.project_name
  storage_class = "STANDARD"
}

resource "google_storage_bucket" "code_storage_bucket" {
  name          = "${var.project_name}-${var.environment}-cs-bucket-code-storage"
  location      = var.default_location
  project       = var.project_name
  storage_class = "STANDARD"
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "../etl/load-cs-to-bq/src"
  output_path = "../etl/load-cs-to-bq/generated/src.zip"
}

resource "google_storage_bucket_object" "cs_object_etl_source_zip" {
  name   = "etl-load-cs-to-bq.zip"
  bucket = google_storage_bucket.raw_data_bucket.name
  source = "../etl/load-cs-to-bq/generated/src.zip"
}

resource "google_cloudfunctions_function" "cloud_function_cs_to_bq" {
  name                  = "${var.project_name}-${var.environment}-cf-cs-to-bq"
  description           = "Cloud function used to insert data from cloud storage to bigquery stage tables"
  runtime               = "python39"
  source_archive_bucket = google_storage_bucket.code_storage_bucket.name
  source_archive_object = google_storage_bucket_object.cs_object_etl_source_zip.name
  available_memory_mb   = 256
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.raw_data_bucket.name
  }
  timeout       = 60
  entry_point   = "main"
  max_instances = 1
}