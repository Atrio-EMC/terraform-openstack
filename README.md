# terraform-openstack

Despliegue automático de Openstack usando terraform. La infraestructura que creamos con terraform es la siguiente:

![schema](https://github.com/iesgn/terraform-openstack/raw/master/img/tos.png)

* La infraestructura de Openstack consta de un controlador y un nodo de computo que se van a crear en dos redes internas (`red-ext` y `red-int`).
* Desde la máquina `cliente` vamos a controlar nuestra instalación de openstack: hay que configurarla como router, para que las máquinas de openstack tengan conexión a internet, desde ella vamos a ejecutar las recetas ansible de instalación y vamos acceder a las instancias creadas.

## Creación de la infraestrucutra con terraform

[Descarga de terraform](https://www.terraform.io/downloads.html).

Clonamos nuestro repositorio:

	$ git clone git@github.com:iesgn/terraform-openstack.git
	$ cd terraform-openstack

A continuación creamos las claves ssh que vamos a utilizar en la creación de las máquinas del escenario:

	$ ssh-keygen -f ~/.ssh/id_rsa.terraform -N ""

Y creamos la infraestructura con la siguiente instrucción:

	$ terraform apply

Va a crear la siguiente infraestructura:

* Una ip flotante para el `cliente`.
* Las redes y subredes correspondientes: `red-ext`, `red-int`.
* 3 instancias: `cliente`, `controlador`,`compute1`
* En cada instancia se ha añadido la clave ssh que hemos creado.
* En el `cliente` se ha añadido la clave privada para poder acceder a las otras máquinas.

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

	 neutron port-list
	...
	| 84e7c85b-33bc-4515-a53d-d94fa5e51dc4 |      | fa:16:3e:6b:55:dd | {"subnet_id": "d3d75f07-8a31-49fb-9b37-ce627ca0f10b", "ip_address": "10.0.0.3"}        |
	...
	| bce643f1-a059-45c3-be36-2d37d3af110a |      | fa:16:3e:c3:b5:1c | {"subnet_id": "b87e6216-5706-470f-a26c-a79b5b4b7288", "ip_address": "192.168.1.1"}     |
	...

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
* Configura permisos de la clave privada
* Instala los paquetes necesarios: git, ansible, aptitude, fabric
* Configura el /etc/hosts

## Configuración de los nodos

Desde el `cliente`  vamos a configurar de forma automática los nodos con fabric, descargamos el script fabric:

	$ curl -L  https://raw.githubusercontent.com/iesgn/terraform-openstack/master/conf/nodos/fabfile.py > fabfile.py
	$ fab -H controller,compute1 main

El script realiza las siguientes tareas:

* Actualiza el sistema
* Levanta la segunda interfaz
* Instala los paquetes necesarios: python, aptitude
* Configura el /etc/hosts

## Ejecución de la receta de ansible

Clonamos nuestro repositorio:

	$ git clone -b ocata https://github.com/iesgn/openstack-ubuntu-ansible.git
	
Y lo ejecutamos:

	$ cd openstack-ubuntu-ansible
	$ ansible-playbook site.yml --sudo