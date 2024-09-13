output "public_ip" {
  value = aws_instance.kubernetes_master.public_ip
}
