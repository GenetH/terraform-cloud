# Note: The bucket name may not work for you since buckets are unique globally in AWS, so you must give it a unique name.


# Enable versioning so we can see the full revision history of our state files


# Enable server-side encryption by default


  
/*

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }cd 
}


terraform {
  backend "s3" {
    bucket         = "genet-dev-terraform-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
*/