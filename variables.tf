variable "secret_key" {}

# Nombre de la red externa de nuestra instalación de Openstack
variable "ext-net" { default = "ext-net"}

# Red externa
variable "ip_subred-ext" {default = "192.168.1.0/24"}
variable "dns_subred-ext" { type="list" default=["192.168.102.2"]}
variable "gateway-ext" {default = "192.168.1.1"}

#Red interna
variable "ip_subred-int" {default = "192.168.221.0/24"}


#Configuración de las máquinas
variable "imagen" {default = "63f0ffcb-7574-4729-bed3-8b934f3ddaa6"} 
variable "sabor" {default = "15"} #m2.large 4G RAM
variable "key_ssh" {default = "key_jdmr"}

#Configuración de las ip

variable "controller_ip_ext" {default = "192.168.1.101"}
variable "controller_ip_int" {default = "192.168.221.101"}

variable "compute1_ip_ext" {default = "192.168.1.102"}
variable "compute1_ip_int" {default = "192.168.221.102"}

