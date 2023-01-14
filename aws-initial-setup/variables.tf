variable "s3_bucket_name" {
  type = string
  default = "<replace_with_bucket_name>"
}

variable "env" {
  type = string
  default = "development"
}

variable "zones" {
  type = map
  default = {
    "north_virginia" = "us-east-1"
  }
}