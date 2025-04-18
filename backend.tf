terraform {
  backend "gcs" {
    bucket  = "my-tfstate-bucket-01"
  }
}
