packer {
  required_plugins {
    amazon = {
      version = "1.3.2"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = "1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "example" {
  ami_name      = "learn-terraform-packer-${local.timestamp}"
  instance_type = "t3a.medium"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"]
  }
  ssh_username = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.example"]

  provisioner "file" {
    source      = "../master.pub"
    destination = "/tmp/tf-packer.pub"
  }

  provisioner "shell" {
    script = "./scripts/setup-al2.sh"
  }
}
