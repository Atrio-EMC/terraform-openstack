# -*- coding: utf-8 -*-
from fabric.api import *
from fabric.contrib.files import exists
env.user   = "ubuntu"
   

def main():
	sudo("apt-get update")
	sudo("apt-get -y upgrade")


	# Compruebo si ens4 está configurada
	try:
		sudo("cat '/etc/network/interfaces.d/50-cloud-init.cfg' |grep ens4")
	except:
		sudo('echo "\nauto ens4\niface ens4 inet dhcp">>/etc/network/interfaces.d/50-cloud-init.cfg')
		sudo("ifup ens4")
	
	# Configuro el router
	try:
		sudo("cat '/etc/network/interfaces.d/50-cloud-init.cfg' |grep iptables")
	except:
		sudo('echo "\nup iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o ens3 -j MASQUERADE">>/etc/network/interfaces.d/50-cloud-init.cfg')
		sudo("systemctl restart networking")
	sudo('sed -i -e s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g /etc/sysctl.conf')
	sudo('sysctl -p')

	# Configura permisos de la clave privada

	run("chmod 400 ~/.ssh/id_rsa")

	# Instalo los paquetes necesarios
	sudo("apt-get -y install ansible git aptitude language-pack-es fabric")
	
	# Configurar el /etc/hosts
	hostname = sudo("cat /etc/hostname")
	if "\n" in hostname:
		hostname=hostname.split("\n")[1]
		hosts='''127.0.0.1 %s
192.168.1.101 controller
192.168.1.102 compute1'''% hostname

		sudo('echo "%s">>/etc/hosts'%hosts)