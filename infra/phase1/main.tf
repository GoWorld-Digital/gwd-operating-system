# infra/phase1/main.tf
# GoWorld.Digital (ATLASHUB DIGITAL LTD — UK #17379237)
# Phase 1 Core Infrastructure: VPC, EC2 Docker Host, S3 Buckets, IAM Instance Profile

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  common_tags = {
    Project       = var.project
    Environment   = var.environment
    Owner         = var.owner
    CompanyNumber = var.company_number
    ManagedBy     = "terraform"
  }
}

# ── VPC & Networking ──────────────────────────────────────────────────────────
resource "aws_vpc" "gwd" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.project}-vpc"
  })
}

resource "aws_internet_gateway" "gwd" {
  vpc_id = aws_vpc.gwd.id

  tags = merge(local.common_tags, {
    Name = "${var.project}-igw"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.gwd.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project}-public-subnet"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.gwd.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gwd.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ── Security Group ────────────────────────────────────────────────────────────
resource "aws_security_group" "gwd_host" {
  name        = "${var.project}-host-sg"
  description = "Security group for GWD Core EC2 host (HTTP/HTTPS, Telemetry WSS, SSH)"
  vpc_id      = aws_vpc.gwd.id

  ingress {
    description = "HTTP (Caddy ACME & redirect)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS (ops, api, crm.goworld.digital)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS HTTP/3 QUIC"
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Telemetry WebSocket (GWD Desktop)"
    from_port   = 18790
    to_port     = 18790
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-host-sg"
  })
}

# ── EC2 Host + Elastic IP ─────────────────────────────────────────────────────
resource "aws_instance" "gwd_host" {
  ami                         = data.aws_ami.ubuntu_2404.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.gwd_host.id]
  key_name                    = var.ec2_key_pair_name
  iam_instance_profile        = aws_iam_instance_profile.gwd_ec2.name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforce IMDSv2
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 40
    encrypted             = true
    delete_on_termination = false
  }

  tags = merge(local.common_tags, {
    Name = "${var.project}-host"
  })
}

resource "aws_eip" "gwd_host" {
  instance = aws_instance.gwd_host.id
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project}-eip"
  })
}

# ── S3 Buckets (Vault Sync & Media Assets) ────────────────────────────────────
resource "aws_s3_bucket" "vault_sync" {
  bucket = var.vault_sync_bucket
  tags   = merge(local.common_tags, { Name = var.vault_sync_bucket })
}

resource "aws_s3_bucket_versioning" "vault_sync" {
  bucket = aws_s3_bucket.vault_sync.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vault_sync" {
  bucket = aws_s3_bucket.vault_sync.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "vault_sync" {
  bucket                  = aws_s3_bucket.vault_sync.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "media_assets" {
  bucket = var.media_assets_bucket
  tags   = merge(local.common_tags, { Name = var.media_assets_bucket })
}

resource "aws_s3_bucket_versioning" "media_assets" {
  bucket = aws_s3_bucket.media_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "media_assets" {
  bucket = aws_s3_bucket.media_assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "media_assets" {
  bucket                  = aws_s3_bucket.media_assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "gwd_host_public_ip" {
  description = "Elastic IP of the GWD Core EC2 host"
  value       = aws_eip.gwd_host.public_ip
}

output "github_actions_role_arn" {
  description = "ARN to set as AWS_GITHUB_ACTIONS_ROLE_ARN in GitHub Secrets"
  value       = var.enable_github_oidc ? aws_iam_role.github_actions[0].arn : null
}

output "vault_sync_bucket_name" {
  description = "S3 bucket for GWD Knowledge Vault sync"
  value       = aws_s3_bucket.vault_sync.id
}

output "media_assets_bucket_name" {
  description = "S3 bucket for GWD Media Assets"
  value       = aws_s3_bucket.media_assets.id
}
