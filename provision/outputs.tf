output "ansible_install_xnat" {
  description = "Run this command from the `xnat-aws/configure` directory to install and configure XNAT."
  value       = "./install_xnat.sh"
}

output "xnat_web_url" {
  description = "Once XNAT has been installed and configured, the web server will be accessible at this URL."
  value       = "http://${module.web_server.xnat_web_hostname}"
}
