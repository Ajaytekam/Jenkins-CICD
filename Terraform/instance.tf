# generate the public-private key
resource "tls_private_key" "pk-generate" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# create aws key-pair
resource "aws_key_pair" "server-key" {
  key_name   = "serverkey"
  public_key = tls_private_key.pk-generate.public_key_openssh
}

# store the generated private key in local disk
resource "local_file" "privateKey_pem" {
  filename = "serverkey.pem"
  content  = tls_private_key.pk-generate.private_key_pem
}


# Jenkins Instance 
#
resource "aws_instance" "jenkins" {
  ami                    = var.AMIS["UBUNTU22"]
  instance_type          = "t2.small"
  availability_zone      = var.ZONE["ZONE1"]
  key_name               = aws_key_pair.server-key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  tags = {
    Name    = "Jenkins-Server"
    Project = "Production"
  }

  # copy file into server
  provisioner "file" {
    source      = "jenkins_install.sh"
    destination = "/tmp/jenkins_install.sh"
  }

  # execute web.sh provision shell script
  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/jenkins_install.sh",
      "sudo /tmp/jenkins_install.sh"
    ]
  }

  # connect to the ssh through ssh
  connection {
    user        = var.USER["UBUNTU"]
    private_key = tls_private_key.pk-generate.private_key_pem
    host        = self.public_ip
  }
}


# SonarQube Instance
#
resource "aws_instance" "sonarqube" {
  ami                    = var.AMIS["UBUNTU22"]
  instance_type          = "t2.medium"
  availability_zone      = var.ZONE["ZONE1"]
  key_name               = aws_key_pair.server-key.key_name
  vpc_security_group_ids = [aws_security_group.sonarqube-sg.id]
  tags = {
    Name    = "Sonarqube-Server"
    Project = "Production"
  }

  # copy file into server
  provisioner "file" {
    source      = "sonarqube_install.sh"
    destination = "/tmp/sonarqube_install.sh"
  }

  # execute web.sh provision shell script
  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/sonarqube_install.sh",
      "sudo /tmp/sonarqube_install.sh"
    ]
  }

  # connect to the ssh through ssh
  connection {
    user        = var.USER["UBUNTU"]
    private_key = tls_private_key.pk-generate.private_key_pem
    host        = self.public_ip
  }
}


# Nexus Instance
#
resource "aws_instance" "nexus" {
  ami                    = var.AMIS["CENTOS7"]
  instance_type          = "t2.medium"
  availability_zone      = var.ZONE["ZONE1"]
  key_name               = aws_key_pair.server-key.key_name
  vpc_security_group_ids = [aws_security_group.nexus-sg.id]
  tags = {
    Name    = "Nexus-Server"
    Project = "Production"
  }

  # copy file into server
  provisioner "file" {
    source      = "nexus_install.sh"
    destination = "/tmp/nexus_install.sh"
  }

  # execute web.sh provision shell script
  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/nexus_install.sh",
      "sudo /tmp/nexus_install.sh"
    ]
  }

  # connect to the ssh through ssh
  connection {
    user        = var.USER["CENTOS"]
    private_key = tls_private_key.pk-generate.private_key_pem
    host        = self.public_ip
  }
}



output "PrivateIP_Jenkins" {
  value = aws_instance.jenkins.private_ip
}

output "PublicIP_Jenkins" {
  value = aws_instance.jenkins.public_ip
}

output "PublicDNS_Jenkins" {
  value = aws_instance.jenkins.public_dns
}


output "PrivateIP_SonarQube" {
  value = aws_instance.sonarqube.private_ip
}

output "PublicIP_SonarQube" {
  value = aws_instance.sonarqube.public_ip
}

output "PublicDNS_SonarQube" {
  value = aws_instance.sonarqube.public_dns
}


output "PrivateIP_Nexus" {
  value = aws_instance.nexus.private_ip
}

output "PublicIP_Nexus" {
  value = aws_instance.nexus.public_ip
}

output "PublicDNS_Nexus" {
  value = aws_instance.nexus.public_dns
}
