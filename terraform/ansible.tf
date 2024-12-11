# Create Ansible inventory file
resource "local_file" "ansible_inventory" {
  filename = "inventory.ini"
  content  = <<EOF
[web_servers]
${aws_instance.ec2.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.private_key_path}
EOF
}
