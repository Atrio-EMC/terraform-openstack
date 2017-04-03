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

	# Instalo los paquetes necesarios
	sudo("apt-get -y install language-pack-es")

# Configurar el /etc/hosts
	hostname = sudo("cat /etc/hostname").split("\n")[1]
	hosts='''127.0.0.1 %s
192.168.1.1 cliente
192.168.1.1 controller
192.168.1.102 compute1'''% hostname

	sudo('echo "%s">>/etc/hosts'%hosts)