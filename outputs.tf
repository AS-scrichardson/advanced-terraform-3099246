output "subnet-id" {
    value = aws_subnet.subnet_1.id
}

output "vpc-id" {
    value = aws_vpc.tf_training.id
}

output "nginx-public-ip" {
    value = aws_instance.nginx.public_ip
}
