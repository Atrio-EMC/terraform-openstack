# terraform-openstack

Despliegue automático de Openstack usando terraform. La infraestructura que creamos con terraform es la siguiente:

![schema](https://github.com/iesgn/terraform-openstack/raw/master/img/tos.png)

* La infraestrucutra de Openstack consta de un controlador y un nodo de computo que se van a crear en dos redes internas (`red-ext` y `red-int`).
* Desde la máquina `cliente` vamos a controlar nuestra instalación de opnstack: hay que configurarla como router, para que las máquinas de openstack tengan conexión a internet, desde ella vamos a ejecutar las recetas ansible de instalación y vamos a cceder a las instancias creadas.

## Creación de la infraestrucutra con terraform

[Descarga de terraform](https://www.terraform.io/downloads.html).

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

Accedemos a `cliente` y actualizamos el sistema:

	$ sudo apt-get update
	$ sudo apt-get upgrade

Nota: Hay que levantar la segunda interfaz, no se hace automáticamente al iniciar la máquina.

	$ sudo nano /etc/network/interfaces.d/50-cloud-init.cfg

	...
	auto ens4
	iface ens4 inet dhcp

	$ sudo ifup ens4





