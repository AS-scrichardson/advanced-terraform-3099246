### PROVIDER
provider "aws" {
  region  = var.region
}

### NETWORK
resource "aws_vpc" "tf_training" {
  cidr_block = var.vpc-cidr
  tags = {
    name = "test vpc for training"
  }
}

## SUBNET
resource "aws_subnet" "subnet_pub" {
  vpc_id = aws_vpc.tf_training.id
  cidr_block = var.public-subnet-cidr
  availability_zone = "us-east-2a"

  tags = {
    name = var.public-subnet-name
  }
}

resource "aws_subnet" "subnet_priv" {
  vpc_id = aws_vpc.tf_training.id
  cidr_block = var.public-subnet-cidr
  availability_zone = "us-east-2b"

  tags = {
    name = var.private-subnet-name
  }
}

# Security group/(firewall in GCP)
resource "aws_security_group" "incoming_data" {
  name    = "incoming-data"
  description = "Allow incoming ping, web traffic."
  vpc_id = aws_vpc.tf_training.id

  tags = {
    name = "allow incoming ping ssh and web traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ping" {
  security_group_id = aws_security_group.incoming_data.id
  ip_protocol = "icmp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = "-1"
  to_port = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_web" {
  security_group_id = aws_security_group.incoming_data.id
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = var.firewall-ports["http"]
  to_port = var.firewall-ports["http"]
}

resource "aws_vpc_security_group_ingress_rule" "allow_web_alt" {
  security_group_id = aws_security_group.incoming_data.id
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = var.firewall-ports["local_http"]
  to_port = var.firewall-ports["local_http"]
}

resource "aws_vpc_security_group_ingress_rule" "allow_range" {
  security_group_id = aws_security_group.incoming_data.id
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = var.firewall-ports["range_start"]
  to_port = var.firewall-ports["range_end"]
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.incoming_data.id
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = var.firewall-ports["ssh"]
  to_port = var.firewall-ports["ssh"]
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.incoming_data.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

# DB SG
resource "aws_security_group" "db_sg" {
  name = "databases"
  description = "SG for DBs"
  vpc_id = aws_vpc.tf_training.id

  tags = {
    name = "db sg"
  }
}

## RDS Instance (Cheapest Configuration)
resource "aws_db_instance" "test_rds" {
  # Engine settings (MySQL is cost-effective)
  engine         = "mysql"
  engine_version = "8.0"
  
  # Instance settings (smallest available)
  instance_class = "db.t3.micro"
  
  # Storage settings (minimal)
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  storage_encrypted    = false
  
  # Database settings
  db_name  = "webapp"
  username = "admin"
  password = "changeme123!"  # Change this in production!
  
  # Network settings
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  
  # Cost optimization settings
  multi_az               = false  # Single AZ for cost savings
  publicly_accessible    = false
  backup_retention_period = 0     # No backups for cost savings
  skip_final_snapshot    = true
  deletion_protection    = false
  
  # Maintenance settings
  auto_minor_version_upgrade = true
  maintenance_window         = "sun:05:00-sun:06:00"
  
  tags = {
    Name = "mysql rds"
    environment = var.environment_map[var.target_environment]
  }
}

### COMPUTE
## NGINX PROXY
resource "aws_instance" "nginx" {
  ami = var.instance-ami
  instance_type = var.environment_machine_type[var.target_environment]
  subnet_id = aws_subnet.subnet_pub.id

  tags = {
    name = "nginx"
    environment = var.environment_map[var.target_environment]
  }
}

## WEB1
resource "aws_instance" "web1" {
  ami = var.instance-ami
  instance_type = var.environment_machine_type[var.target_environment]
  subnet_id = aws_subnet.subnet_pub.id

  tags = {
    name = "Web server1"
    environment = var.environment_map[var.target_environment]
  }
}
## WEB2
resource "aws_instance" "web2" {
  ami = var.instance-ami
  instance_type = var.environment_machine_type[var.target_environment]
  subnet_id = aws_subnet.subnet_pub.id

  tags = {
    name = "Web server2"
    environment = var.environment_map[var.target_environment]
  }
}
## WEB3
/* resource "aws_instance" "web1" {
  ami = var.instance-ami
  instance_type = var.instance-size
  subnet_id = aws_subnet.subnet_pub.id

  tags = {
    name = "Web instance"
  }
} */

# ## DB
# resource "aws_instance" "db" {
#   ami = var.instance-ami
#   instance_type = var.environment_machine_type[var.target_environment]
#   subnet_id = aws_subnet.subnet_pub.id

#   tags = {
#     name = "db instance"
#     environment = var.environment_map[var.target_environment]
#   }
# }
