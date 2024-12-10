terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8"
    }

    null = {
      source = "hashicorp/null"
      version = "~> 3.2"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.6"      
    }

    template = {
      source = "hashicorp/template"
      version = "~> 2.2"
    }
  }

  backend "s3" {
    key    = "main-site-wordpress/terraform.tfstate"
    encrypt = true
    region = "us-east-1"
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "random_string" "random" {
  length = 4
  special = false
  upper = false  
}

locals {
  account_id = data.aws_caller_identity.this.account_id
  certificate = data.aws_acm_certificate.bigtrade.arn
  az1 = data.aws_availability_zones.azs.names[0]
  az2 = data.aws_availability_zones.azs.names[1]
  az3 = data.aws_availability_zones.azs.names[2]
  random = random_string.random.result
  secrets = {
    vpc_cidr = jsondecode(data.aws_secretsmanager_secret_version.wordpress-secrets.secret_string)["CIDR_BLOCK"]
    public_subnet1 = jsondecode(data.aws_secretsmanager_secret_version.wordpress-secrets.secret_string)["PUBLIC_SUBNET_1"]
    public_subnet2 = jsondecode(data.aws_secretsmanager_secret_version.wordpress-secrets.secret_string)["PUBLIC_SUBNET_2"]
    private_subnet1 = jsondecode(data.aws_secretsmanager_secret_version.wordpress-secrets.secret_string)["PRIVATE_SUBNET_1"]
    private_subnet2 = jsondecode(data.aws_secretsmanager_secret_version.wordpress-secrets.secret_string)["PRIVATE_SUBNET_2"]
    database_name = jsondecode(data.aws_secretsmanager_secret_version.wordpress-secrets.secret_string)["DATABASE_NAME"]
    database_username = jsondecode(data.aws_secretsmanager_secret_version.wordpress-secrets.secret_string)["DATABASE_USERNAME"]
    database_password = jsondecode(data.aws_secretsmanager_secret_version.wordpress-secrets.secret_string)["DATABASE_PASSWORD"]
  }
}

module "wordpress" {
  source = "./modules/wordpress"
  az1 = local.az1
  az2 = local.az2
  az3 = local.az3
  profile = var.profile
  project_name = var.project_name
  random = local.random
  region = var.region

  aws_ami = var.aws_ami
  aws_ami_owner = var.aws_ami_owner
  instance_class = var.instance_class
  instance_type = var.instance_type
  prv_key = var.prv_key
  pub_key = var.pub_key
  root_volume_size = var.root_volume_size
  database_name = local.secrets["database_name"]
  database_username = local.secrets["database_username"]
  database_password = local.secrets["database_password"]

  private_subnet1 = local.secrets["public_subnet1"]
  private_subnet2 = local.secrets["public_subnet2"]
  public_subnet1 = local.secrets["private_subnet1"]
  public_subnet2 = local.secrets["private_subnet2"]
  vpc_cidr = local.secrets["vpc_cidr"]
}

module "alb" {
  source = "./modules/alb"
  project_name = var.project_name
  random = local.random
  certificate_arn = local.certificate
  instance_id = module.wordpress.instance_id
  ec2_security_group_id = module.wordpress.ec2_security_group_id
  public_subnet_az1_id = module.wordpress.public_subnet_az1_id
  public_subnet_az2_id = module.wordpress.public_subnet_az2_id
  vpc_id = module.wordpress.vpc_id
}