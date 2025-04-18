terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  required_version = ">= 0.12"
}

provider "google" {
  credentials = file("gcp-credentials.json")
  project = var.project_id
  region  = var.region
}