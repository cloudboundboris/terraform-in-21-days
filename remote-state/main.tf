resource "aws_s3_bucket" "remote_state" {
    bucket = "terraform-remote-state-bl"
}

resource "aws_dynamodb_table" "terraform-remote-state-db" {
  name           = "terraform-remote-state-db"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"


  attribute {
    name = "LockID"
    type = "S"
  }

}