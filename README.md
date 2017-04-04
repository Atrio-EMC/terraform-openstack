# terraform-openstack

Despliegue automático de Openstack usando terraform. La infraestructura que creamos con terraform es la siguiente:

![schema](https://github.com/iesgn/terraform-openstack/raw/master/img/tos.png)

* La infraestructura de Openstack consta de un controlador y un nodo de computo que se van a crear en dos redes internas (`red-ext` y `red-int`).
* Desde la máquina `cliente` vamos a controlar nuestra instalación de opnstack: hay que configurarla como router, para que las máquinas de openstack tengan conexión a internet, desde ella vamos a ejecutar las recetas ansible de instalación y vamos acceder a las instancias creadas.

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
	address = 172.22.X.X

Si queremos eliminar la infraestrucutara creada:

	$ terraform destroy

## Configuración del `cliente` 

Todas estas configuraciones se van a realizar desde nuestro host. Antes de configurar la máquina como router, hay que desactivar el antispoofing gestionando la extensión `port-security`, para ello:

### Instalar nova-cli y neutron-cli

Voy a crear un entorno virtual para instalar los clientes de openstack:

	$ apt-get install build-essential python-virtualenv python-dev libssl-dev libffi-dev

	$ virtualenv os
	$ source os/bin/activate
	(os)$ pip install requests python-novaclient python-neutronclient

Siguiendo las siguientes [instrucciones](https://wiki.openstack.org/wiki/Neutron/ML2PortSecurityExtensionDriver) (recordamos que debe estar habiliatado la extensión `port security`), hay que quitar el grupo de seguridad a `cliente`:

	nova remove-secgroup cliente default


Y desactivar el flag `port_security_enabled` en los dos puertos correspondientes a las interfaces de ´cliente´:

	neutron port-update  <Port_id> --port-security-enabled=False


### Configuramos de forma automática el `cliente`

Necesitamos instalar [fabric](http://www.fabfile.org/):

	# apt-get install fabric

O en un entorno virtual:

	$ virtualenv fabric
	$ source fabric/bin/activate
	(fabric)$ pip install appdirs pyparsing fabric  

A continuación ejecutamos la configuración de fabric:

	$ cd conf/cliente
	$ fab -H 172.22.X.X main

El script realiza las siguientes tareas:

* Actualiza el sistema
* Levanta la segunda interfaz
* Configura el enrutamiento 
* Instala los paquetes necesarios: git, ansible, aptitude, fabric
* Crea una clave ssh
* Configura el /etc/hosts

## Configuración de los nodos

Desde el `cliente`  vamos a configurar de forma automática los nodos con fabric, descargamos el script fabric:

	$ curl -L  https://raw.githubusercontent.com/iesgn/terraform-openstack/master/conf/nodos/fabfile.py > fabfile.py
	$ fab -H controller,compute1 main

El script realiza las siguientes tareas:

* Actualiza el sistema
* Levanta la segunda interfaz
* Instala los paquetes necesarios: python, aptitude
* Copia la clave publica ssh del cliente al nodo
* Configura el /etc/hosts

## Ejecución de la receta de ansible

Clonamos nuestro repositorio:

	$ git clone -b ocata git@github.com:iesgn/openstack-ubuntu-ansible.git

Y lo ejecutamos:

	$ cd openstack-ubuntu-ansible
	$ ansible-playbook site.yml --sudo