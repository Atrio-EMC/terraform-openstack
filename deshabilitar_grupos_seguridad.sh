#!/usr/bin/env bash

if type nova >/dev/null; then
    echo "Quitamos los grupos de seguridad de compute1 y controller"
    nova remove-secgroup controller default
    nova remove-secgroup compute1 default
    if type neutron >/dev/null; then
	for direccion_IP in `grep _ip_ variables.tf | cut -d= -f2|cut -d\" -f2`
	do
	    PORT_ID=$(neutron port-list|grep $direccion_IP|awk '{print $2}')
	    neutron port-update $PORT_ID --port-security-enabled=False
	done
    else
	echo "No existe el ejecutable neutron"
    fi
else
    echo "No existe el ejecutable nova"
fi
