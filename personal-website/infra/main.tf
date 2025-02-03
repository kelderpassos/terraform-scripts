terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }

  backend "s3" {
    key            = "personal-website/terraform.tfstate"
    encrypt        = true
    region         = "us-east-1"
    dynamodb_table = "dynamodb-state-locking"
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

locals {
  file_path = "${path.root}/../src/"
}

resource "null_resource" "sync_s3" {
  depends_on = [ module.s3 ]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "aws s3 --profile=${var.profile} sync ${local.file_path} s3://${var.bucket_name}"
  }
}


module "acm" {
  source      = "./modules/acm"
  domain_name = var.domain_name
  environment = var.environment
}

module "cloudfront" {
  source        = "./modules/cloudfront"
  bucket_domain = module.s3.bucket_domain
  bucket_name   = module.s3.bucket_name
  certificate   = module.acm.certificate_arn
  domain_name   = var.domain_name
  environment   = var.environment
  zone_id       = module.route53.zone_id
}

module "route53" {
  source                 = "./modules/route53"
  certificate_arn        = module.acm.certificate_arn
  certificate_validation = module.acm.certificate_validation
  domain_name            = var.domain_name
  environment            = var.environment
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  environment = var.environment
  file_path   = local.file_path
}