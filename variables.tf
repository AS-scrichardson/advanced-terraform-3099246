### VARIABLES
variable "region" {
  type = string
  default = "us-east-2"
}

variable "vpc-cidr" {
  type = string
  default = "172.30.200.0/22"
}

variable "public-subnet-name" {
  type = string
  default = "subnet-the-first"
}

variable "private-subnet-name" {
  type = string
  default = "subnet-the-private"
}

variable "public-subnet-cidr" {
  type = string
  #default = "172.30.200.0/24"
}

variable "private-subnet-cidr" {
  type = string
  #default = "172.30.201.0/24"
}

variable "instance-size" {
  type = string
  default = "t3.nano"
}

variable "instance-ami" {
  type = string
  default = "ami-0b016c703b95ecbe4"
}

variable "firewall-ports" {
  type = map(string)
  default = {
    "http" = "80", 
    "local_http" = "8080", 
    "range_start" = "1000",
    "range_end" = "2000",
    "ssh" = "22"
  }
}

variable "compute-source-tags" {
    type = list
    default = ["web"]
}

variable "target_environment" {
  default = "DEV"
}

variable "environment_list" {
  type = list(string)
  default = ["DEV","QA","STAGE","PROD"]
}

variable "environment_map" {
  type = map(string)
  default = {
    "DEV" = "dev",
    "QA" = "qa",
    "STAGE" = "stage",
    "PROD" = "prod"
  }
}

variable "environment_machine_type" {
  type = map(string)
  default = {
    "DEV" = "t3.nano",
    "QA" = "t3.nano",
    "STAGE" = "t3.nano",
    "PROD" = "t3.nano"
  }
}

variable "environment_instance_settings" {
  type = map(object({machine_type=string, tags=list(string)}))
  default = {
    "DEV" = {
      machine_type = "t3.nano"
      tags = ["dev"]
    },
   "QA" = {
      machine_type = "t3.nano"
      tags = ["qa"]
    },
    "STAGE" = {
      machine_type = "t3.nano"
      tags = ["stage"]
    },
    "PROD" = {
      machine_type = "t3.nano"
      tags = ["prod"]
    }
  }
}