resource "google_storage_bucket" "secure_bucket" {
  name     = "my-secure-prod-bucket"
  location = var.region

  uniform_bucket_level_access = true
  force_destroy               = false
}
