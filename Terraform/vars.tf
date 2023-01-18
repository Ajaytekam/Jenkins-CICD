variable "REGION" {
  default = "us-east-1"
}

variable "ZONE" {
  type = map(any)
  default = {
    ZONE1 = "us-east-1a"
    ZONE2 = "us-east-1b"
    ZONE3 = "us-east-1c"
  }
}

variable "AMIS" {
  type = map(any)
  default = {
    UBUNTU22 = "ami-06878d265978313ca"
    CENTOS7  = "ami-002070d43b0a4f171"
  }
}

variable "USER" {
  type = map(any)
  default = {
    UBUNTU = "ubuntu"
    CENTOS = "centos"
  }
}

variable "MYIP" {
  default = "USER_IP_TO_CONNECT/32"
}

