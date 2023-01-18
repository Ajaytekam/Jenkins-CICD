# Jenkins Security Group
resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  description = "Jenkins Security Group"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]
  }

  tags = {
    Name = "jenkins-sg"
  }
}


# SonarQube Security Group
resource "aws_security_group" "sonarqube-sg" {
  name        = "sonarqube-sg"
  description = "SonarQube Security Group"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]
  }

  tags = {
    Name = "sonarqube-sg"
  }
}


# Nexus Security Group
resource "aws_security_group" "nexus-sg" {
  name        = "nexus-sg"
  description = "Nexus  Security Group"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]
  }


  tags = {
    Name = "nexus-sg"
  }
}


resource "aws_security_group_rule" "jenkins_from_sonarqube_ingress" {
  type                     = "ingress"
  from_port                = 9000
  to_port                  = 9000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sonarqube-sg.id
  source_security_group_id = aws_security_group.jenkins-sg.id
}

resource "aws_security_group_rule" "sonarqube_from_jenkins_ingress" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins-sg.id
  source_security_group_id = aws_security_group.sonarqube-sg.id
}

resource "aws_security_group_rule" "jenkins_from_nexus_ingress" {
  type                     = "ingress"
  from_port                = 8081
  to_port                  = 8081
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nexus-sg.id
  source_security_group_id = aws_security_group.jenkins-sg.id
}

