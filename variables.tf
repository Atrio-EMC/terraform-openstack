
# Nombre de la red externa e interna de nuestra instalación de Openstack
variable "ext-net" { default = "ext-net"}
variable "int-net" { default = "demo-net"}


#Red interna
variable "ip_subred-int" {default = "192.168.0.0/24"}


#Configuración de las máquinas
variable "imagen" {default = "Ubuntu Xenial 16.04 LTS"} 
variable "sabor" {default = "m2.large"} 
variable "sabor_controller" {default = "m2.xlarge"} 
variable "key_ssh" {default = "terraform_key"}
variable "ssh_key_file" {default = "~/.ssh/id_rsa.terraform"}


#Configuración de las ip

variable "controller_ip_ext" {default = "10.0.0.10"}
variable "controller_ip_int" {default = "192.168.0.10"}

variable "compute1_ip_ext" {default = "10.0.0.11"}
variable "compute1_ip_int" {default = "192.168.0.11"}

#Configuración del volumen

variable "size" {default = "10"}



