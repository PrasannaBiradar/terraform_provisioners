provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "local_instance" {
    ami = "ami-08b5b3a93ed654d19"
    instance_type = "t2.micro"
    tags = {
      Name = "local-exec-server"
    }
    key_name = "terraform-key"
    provisioner "local-exec" {
        command = "echo Instance ${self.id} has been created > instance_id.txt"
    }

    connection {
          type = "ssh"
          user = "ec2-user"
          private_key = file("/root/terraform/provisioners/terraform-key.pem")
          host = self.public_ip
        }

    provisioner "remote-exec" {
        inline = [ 
            "sudo yum update -y",
            "sudo yum install httpd -y",
            "sudo systemctl start httpd",
            "sudo systemctl enable httpd"
         ]
    }

    provisioner "file" {
        source = "local_script.sh"
        destination = "/home/ec2-user/remote_script.sh"
    }
}

output "public_ip" {
  value = aws_instance.local_instance.public_ip
}
