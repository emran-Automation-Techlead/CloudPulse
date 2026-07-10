# ---------------------------------------------------------------------------
# PLAIN ENGLISH: Terraform needs to remember what it already built, so it
# doesn't try to recreate things that already exist. This file tells it
# to store that memory ("state") in a private S3 bucket instead of on a
# single laptop, and to use a DynamoDB table as a lock so two people (or
# two CI runs) can never make conflicting changes at the same time.
#
# Fill in the bucket/table names below with ones you've created for this
# purpose before running `terraform init`. They are deliberately left as
# placeholders rather than auto-created, since remote state storage should
# outlive any single `terraform apply`/`destroy` cycle.
# ---------------------------------------------------------------------------

terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_YOUR_TF_STATE_BUCKET"
    key            = "cloudpulse/dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "REPLACE_WITH_YOUR_TF_LOCK_TABLE"
    encrypt        = true
  }
}
