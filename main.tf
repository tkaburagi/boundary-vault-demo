provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.project
  region  = var.gcp_region
  zone    = "asia-northeast1-a"
}
