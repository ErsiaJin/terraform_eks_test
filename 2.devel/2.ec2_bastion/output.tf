output "ec2_bastion_public_ip" {
  description = "The public IP of the Bastion EC2"
  value       = "${aws_eip.bastion_eip.public_ip}"
}