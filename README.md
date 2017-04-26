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

Si queremos eliminar la infraestructura creada:

	$ terraform destroy

## Configuración de la red

Para permitir la comunicación entre las máquinas de nuestro escenario, hay que desactivar el antispoofing gestionando la extensión `port-security` en todas las redes de nuestra infraestructura.

### Instalar nova-cli y neutron-cli

Voy a crear un entorno virtual, en mi puesto de trabajo, para instalar los clientes de openstack:

	$ apt-get install build-essential python-virtualenv python-dev libssl-dev libffi-dev

	$ virtualenv os
	$ source os/bin/activate
	(os)$ pip install requests python-novaclient python-neutronclient

Siguiendo las siguientes [instrucciones](https://wiki.openstack.org/wiki/Neutron/ML2PortSecurityExtensionDriver) (recordamos que debe estar habiliatado la extensión `port security`), hay que quitar el grupo de seguridad de las máquinas:

	nova remove-secgroup cliente default
	nova remove-secgroup controller default
	nova remove-secgroup compute1 default


Y desactivar el flag `port_security_enabled` en los puertos correspondientes a las interfaces de ´cliente´:

	neutron port-list

	...	
	| 52791b7f-8e41-49f3-87cc-1b876ed002cb |      | fa:16:3e:a7:f9:8c | {"subnet_id": "cd9ccf2c-efc3-4222-b2a6-a1d0476e672e", "ip_address": "192.168.1.101"}   |
	| 54ea6739-fb5d-4d8e-8283-e48aea7daa4f |      | fa:16:3e:74:dd:c0 | {"subnet_id": "cd9ccf2c-efc3-4222-b2a6-a1d0476e672e", "ip_address": "192.168.1.102"}   |
	| 562f0933-ecff-40e1-abe8-1a8d13e2c61e |      | fa:16:3e:4a:34:58 | {"subnet_id": "4938e49e-4a39-4758-9a7d-42870aa85971", "ip_address": "192.168.221.102"} |
	| 651a41bd-0a56-496d-9a00-44aebb9adc3b |      | fa:16:3e:e2:9d:35 | {"subnet_id": "b00bed14-5b74-4402-a524-bebf2e10ff66", "ip_address": "10.0.0.10"}       |
	| 8d9e0572-302c-4403-8f3f-577d73517941 |      | fa:16:3e:3c:b9:52 | {"subnet_id": "4938e49e-4a39-4758-9a7d-42870aa85971", "ip_address": "192.168.221.101"} |
	| e2057c3b-b99b-45a0-ae2c-587cc38e211c |      | fa:16:3e:8e:17:8f | {"subnet_id": "cd9ccf2c-efc3-4222-b2a6-a1d0476e672e", "ip_address": "192.168.1.1"}     |
	...
	
	neutron port-update  <Port_id> --port-security-enabled=False


## Configuración del `cliente` 

Desde nuestro puesto de trabajo, necesitamos instalar [fabric](http://www.fabfile.org/):

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

## Acceder a horizon a través de `cliente`

Vamos a instalar un proxy inverso en `cliente` con apache2, para ello:

	$ apt-get install apache2

	$ a2enmod proxy
	$ a2enmod proxy_wstunnel
	$ a2enmod proxy_http

Y el fichero de configuración `/etc/apache2/sites-available/000-default`:

	<VirtualHost *:80>
    #ServerName publicdomin.name
    ProxyPreserveHost On
    ProxyPass / http://192.168.1.101/
    ProxyPassReverse / http://192.168.1.101/

	</VirtualHost>

	<VirtualHost *:6080>
    #ServerName publicdomain.name
    ProxyPreserveHost On
    ProxyRequests On
    ProxyPass /websockify ws://192.168.1.101:6080/websockify  retry=3
    ProxyPass / http://192.168.1.101:6080/ retry=1
    ProxyPassReverse / http://192.168.1.101:6080/ retry=1
	</VirtualHost>

	$ service apache2 restart

Para más información:[https://ask.openstack.org/en/question/7102/connecting-vnc-from-wan-behind-a-apache-246-proxy/](https://ask.openstack.org/en/question/7102/connecting-vnc-from-wan-behind-a-apache-246-proxy/).