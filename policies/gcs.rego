package main

default deny = []

deny[msg] {
  some i
  resource := input.resource_changes[i]
  resource.type == "google_storage_bucket_iam_member"
  member := resource.change.after.member
  (member == "allUsers" or member == "allAuthenticatedUsers")
  msg := sprintf("Public GCS bucket detected: member '%s' is not allowed.", [member])
}
