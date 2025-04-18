package main

deny[msg] if {
  banned := {"allUsers", "allAuthenticatedUsers"}
  input.resource_changes[_].type == "google_storage_bucket_iam_member"
  member := input.resource_changes[_].change.after.member
  member == banned[_]
  msg := sprintf("Public GCS bucket detected: member '%s' is not allowed.", [member])
}
