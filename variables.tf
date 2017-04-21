#auth
variable "user_name" { default = "demo" }
variable "tenant_name" { default = "demo" }
variable "domain_name" { default = "default" }
variable "secret_key" {}
variable "auth_url" { default = "https://jupiter.gonzalonazareno.org:5000/v3"}
variable "cacert_file" {default = "gonzalonazareno.crt" }


# Nombre de la red externa de nuestra instalación de Openstack
variable "ext-net" { default = "ext-net"}
variable "red_ext_cliente" { default = "demo-net"}


# Red externa
variable "ip_subred-ext" {default = "192.168.1.0/24"}
variable "dns_subred-ext" { type="list" default=["192.168.102.2"]}
variable "gateway-ext" {default = "192.168.1.1"}

#Red interna
variable "ip_subred-int" {default = "192.168.221.0/24"}


#Configuración de las máquinas
variable "imagen" {default = "Ubuntu Xenial 16.04 LTS"} 
variable "sabor" {default = "m2.large"} 
variable "key_ssh" {default = "terraform_key"}
variable "ssh_key_file" {default = "~/.ssh/id_rsa.terraform"}


#Configuración de las ip

variable "controller_ip_ext" {default = "192.168.1.101"}
variable "controller_ip_int" {default = "192.168.221.101"}

variable "compute1_ip_ext" {default = "192.168.1.102"}
variable "compute1_ip_int" {default = "192.168.221.102"}

