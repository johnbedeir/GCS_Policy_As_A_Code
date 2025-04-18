# GCS Bucket Public Access Policy Enforcement

This project is built with **Terraform** and leverages **GitHub Actions** and **Open Policy Agent (OPA)** to securely deploy Google Cloud Storage (GCS) buckets and enforce that **no bucket is publicly accessible**.

---

## What This Project Does

- Provisions GCS buckets using Terraform.
- Uses a GitHub Actions workflow to:
  1. Authenticate to GCP using a service account.
  2. Run `terraform init`, `plan`, and `apply`.
  3. Convert the plan to JSON.
  4. Evaluate the plan using a custom OPA Rego policy.
  5. Block deployment if public access (`"allUsers"` or `"allAuthenticatedUsers"`) is detected.

---

## Where is the Terraform State Stored?

Terraform uses a **remote backend** to store the `tfstate` file securely in a **Google Cloud Storage (GCS)** bucket:

```hcl
terraform {
  backend "gcs" {
    bucket  = "my-tfstate-bucket"
    prefix  = "env/prod"
    project = "your-gcp-project-id"
  }
}
```

This ensures consistent state management across CI and teams.

---

## Required GitHub Secrets

Before running the GitHub Actions workflow, you must add the following secrets to your repo:

### How to Add Secrets:

1. Go to your GitHub repository → `Settings` → `Secrets and variables` → `Actions`
2. Click `New repository secret`

| Secret Name                   | Description                                          |
| ----------------------------- | ---------------------------------------------------- |
| `GCP_SERVICE_ACCOUNT_KEY_B64` | Base64-encoded GCP service account key (JSON format) |
| `GCP_PROJECT_ID`              | Your GCP project ID (e.g., `my-gcp-project`)         |
| `GCP_REGION`                  | GCP region for the bucket (e.g., `us-central1`)      |

---

## Workflow Overview

The workflow runs on every pull request to the `main` branch.

### Key Workflow Steps:

1. Checkout code
2. Decode and activate GCP service account credentials
3. Run `terraform init` and `plan`
4. Convert plan to JSON
5. Run OPA policy to detect public IAM bindings
6. Deny deployment if `"allUsers"` or `"allAuthenticatedUsers"` is found
7. If clean, apply infrastructure with `terraform apply`

---

## Policy Logic (OPA)

Located in `policies/gcs.rego`, this Rego policy **blocks any IAM member** that grants public access:

```rego
package main

deny[msg] if {
  banned := {"allUsers", "allAuthenticatedUsers"}
  input.resource_changes[_].type == "google_storage_bucket_iam_member"
  member := input.resource_changes[_].change.after.member
  member == banned[_]
  msg := sprintf("Public GCS bucket detected: member '%s' is not allowed.", [member])
}
```

---

## Result

If a PR attempts to add public access to a GCS bucket, the CI workflow **fails automatically** — preventing insecure deployments to production.
