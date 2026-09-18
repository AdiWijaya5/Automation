output "server_public_ips" {
  value = {
    ubuntu             = aws_eip.eip_ubuntu.public_ip
    debian             = aws_eip.eip_debian.public_ip
    ubuntu_ansible_1   = aws_eip.eip_ubuntu_ansible_1.public_ip
    ubuntu_ansible_2   = aws_eip.eip_ubuntu_ansible_2.public_ip
  }
  description = "Daftar IP Publik semua server EC2"
}
