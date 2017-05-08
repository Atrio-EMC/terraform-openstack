# -*- coding: utf-8 -*-
from fabric.api import *
from fabric.contrib.files import exists
env.user   = "ubuntu"
   

def main():
    # Configurar el /etc/hosts
    put('./hosts','/etc/hosts',use_sudo=True)

    # Actualizar el sistema
    sudo("apt-get update")
    sudo("apt-get -y upgrade")

    # Comprobar si ens4 está configurada
    # try:
    #     sudo("cat '/etc/network/interfaces.d/50-cloud-init.cfg' |grep ens4")
    # except:
    #     sudo('echo "\nauto ens4\niface ens4 inet dhcp">>/etc/network/interfaces.d/50-cloud-init.cfg')
    #     sudo("ifup ens4")
	

    # Copiar la clave ssh y configurar permisos:
    put('~/.ssh/id_rsa.terraform','~/.ssh/id_rsa', mode=0600)

    # Instalar aptitude
    sudo("apt-get -y install aptitude language-pack-es python python-shade")
	
