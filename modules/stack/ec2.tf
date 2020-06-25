data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "image-id"
    values = [var.misc_instance_ami]
  }

  # from the EC2 > Images > Public Images
  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "misc_instance_key" {
  key_name   = "ec2 key"
  public_key = var.public_key_for_ec2
}


resource "aws_instance" "misc_instance" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.misc_instance_type
  key_name = aws_key_pair.misc_instance_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_instance.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  root_block_device {
    volume_size = 50
  }

  tags = {
    Name = data.aws_ami.ubuntu.name
    Environment = var.environment
  }

  subnet_id = aws_subnet.public[0].id
}
