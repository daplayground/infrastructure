# Find the latest AMI created by Packer
data "aws_ami" "latest_packer_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["learn-terraform-packer-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_key_pair" "kubernetes_master" {
  key_name   = "master"
  public_key = file(var.ssh_public_key)
}

resource "aws_security_group" "sg_22_80" {
  name   = "sg_22"
  vpc_id = data.terraform_remote_state.bootstrap.outputs.vpc_id

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "cloudinit_config" "server_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = file("${path.module}/templates/server.yaml")
    filename     = "server.yaml"
  }
}

resource "aws_instance" "kubernetes_master" {
  ami                         = data.aws_ami.latest_packer_ami.id
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.kubernetes_master.key_name
  subnet_id                   = data.terraform_remote_state.bootstrap.outputs.subnet_id
  vpc_security_group_ids      = [aws_security_group.sg_22_80.id]
  associate_public_ip_address = true
  user_data_base64            = data.cloudinit_config.server_config.rendered
  user_data_replace_on_change = true


  tags = {
    Name = "Kubernetes Master"
  }
}

resource "null_resource" "wait_for_ssh" {
  depends_on = [aws_instance.kubernetes_master]
  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for SSH to be ready..."
      while ! nc -zv ${aws_instance.kubernetes_master.public_ip} 22; do sleep 5; done
      echo "SSH is ready!"
    EOT
  }
}

resource "null_resource" "wait_for_pods_and_fetch_kubeconfig" {
  depends_on = [aws_instance.kubernetes_master, null_resource.wait_for_ssh]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for .kube/config to be created on the Kubernetes master node..."
      until scp -o StrictHostKeyChecking=no -i ${var.ssh_private_key} ec2-user@${aws_instance.kubernetes_master.public_ip}:/home/ec2-user/.kube/config ./kubeconfig; do
        echo "Waiting for .kube/config..."
        sleep 10
      done
      # Set the server IP to the public IP of the master node
      sed -i "s/server: https:\\/\\/.*:6443/server: https:\\/\\/${aws_instance.kubernetes_master.public_ip}:6443/" ./kubeconfig
      echo "Kubeconfig saved to ./kubeconfig"
    EOT
  }
}

resource "null_resource" "apply_calico_manifest" {
  depends_on = [null_resource.wait_for_pods_and_fetch_kubeconfig]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for Kubernetes API to be ready..."
      until kubectl --kubeconfig=./kubeconfig get nodes; do
        echo "Waiting for Kubernetes API..."
        sleep 10
      done
      echo "Kubernetes API is ready. Applying Calico manifest..."
      kubectl --kubeconfig=./kubeconfig apply -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml
      echo "Calico network installed successfully."
    EOT
  }
}
