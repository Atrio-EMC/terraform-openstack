# terraform-openstack

Despliegue automático de Openstack usando terraform. La infraestructura que creamos con terraform es la siguiente:

![schema](https://github.com/iesgn/terraform-openstack/raw/master/img/tos.png)

* La infraestrucutra de Openstack consta de un controlador y un nodo de computo que se van a crear en dos redes internas (`red-ext` y `red-int`).
* Desde la máquina `cliente` vamos a controlar nuestra instalación de opnstack: hay que configurarla como router, para que las máquinas de openstack tengan conexión a internet, desde ella vamos a ejecutar las recetas ansible de instalación y vamos a cceder a las instancias creadas.

## Creación de la infraestrucutra con terraform

[Descarga de terraform](https://www.terraform.io/downloads.html).

Clonamos nuestro repositorio:

	$ git clone git@github.com:iesgn/terraform-openstack.git
	$ cd terraform-openstack
	$ terraform apply

Va a crear la siguiente infraestructura:

* Una ip flotante para el `cliente`.
* Las redes y subredes correspondientes: `red-ext`, `red-int`.
* 3 instancias: `cliente`, `controlador`,`compute1`

Puedes modificar los distintos parámetros de configuración en el fichero `variables.tf`.

Una vez concluido nos muestra la ip flotante:

	Outputs:
	address = 172.22.201.151

Si queremos eliminar la infraestrucutara creada:

	$ terraform destroy

## Configuración de `cliente` como router



Antes de configurar la máquina como router, hay que desactivar el antispoofing gestionando la extensión `port-security`, para ello:

### Instalar nova-cli y neutron-cli

Voy a crear un entorno virtual para instalar los clientes de openstack:

	$ apt-get install build-essential python-virtualenv python-dev python-virtualenv libssl-dev libffi-dev

	$ virtualenv os
	$ source os/bin/activate
	(os)$ pip install requests python-novaclient==6.0.0 python-neutronclient==6.0.0

### Ejecuto el script `antispoofing.sh`

	(os)$ source demo-openrc.sh
	(os)$ cd conf/antispoofing
	(os)$ chmod +x antispoofing.sh
	(os)$ ./antispoofing.sh
	(os)$ deactivate

Este script quita los grupos de seguridad de `cliente` y desactiva la extensión `port-security` de las dos redes a la que está conectada.


### Configuramos de forma automática el `cliente`

Necesitamos intalar [fabric](http://www.fabfile.org/):

	# apt-get install fabric

O en un entorno virtual:

	$ virtualenv fabric
	$ source fabric/bin/activate
	(fabric)$ pip install appdirs pyparsing fabric  

A continuación ejecutamos la configuración de fabric:

	$ cd conf/cliente
	$ tab -H 172.22.201.151 main

El script realiza las siguientes tareas:

* Actualiza el sistema
* Levanta la segunda interfaz
* Configura el enrutamiento 
* Instala los paquetes necesarios: git, ansible, aptitude
* Copia la clave privada al cliente para poder acceder a los nodos