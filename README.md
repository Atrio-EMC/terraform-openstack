# terraform-openstack

Despliegue automático de Openstack usando terraform. La infraestructura que creamos con terraform es la siguiente:

![schema](https://github.com/iesgn/terraform-openstack/raw/escenario2/img/tos.png)

* La infraestructura de Openstack consta de un controlador y un nodo
  de cómputo que se van a conectar en la red interna de nuestro
  proyecto y en una red interna que hemos creado (`red-int`).
* La máquina `controller` se le asigna una ip flotante para realizar
  la instalación de Openstack y poder acceder a los recursos creados.

## Creación de la infraestrucutra con terraform

[Descarga de terraform](https://www.terraform.io/downloads.html).

Clonamos nuestro repositorio:

	$ git clone -b escenario2 git@github.com:iesgn/terraform-openstack.git
	$ cd terraform-openstack

A continuación creamos las claves ssh que vamos a utilizar en la
creación de las máquinas del escenario:

	$ ssh-keygen -f ~/.ssh/id_rsa.terraform -N ""

Cargamos las credenciales de OpenStack (en este caso están en el
fichero demo-openrc.sh)::

	$ source demo-openrc.sh

Puedes modificar los distintos parámetros de configuración en el
fichero `variables.tf`. Normalmente solo será necesario cambiar la
variable `int-net` donde se indica el nombre de la red interna de tu
infraestructura Openstack donde se van a conectar las máquinas, las
IPs correspondientes a esta red ("controller_ip_ext" y
"compute1_ip_ext"), los sabores a utilizar (con un mínimo de 4 GiB de
RAM) y el nombre de la imagen de Ubuntu Xenial disponible.

Y creamos la infraestructura con la siguiente instrucción:

	$ terraform apply

Va a crear la siguiente infraestructura:

* Dos IPs flotantes, una para el controlador y otra para el nodo de
  computación
* La clave ssh que hemos creado
* Las red `red-int`.
* 2 instancias: `controller`,`compute1`
* En cada instancia se ha añadido la clave ssh que hemos creado.
* En el `controller` se ha añadido la clave privada para poder acceder
  a las otras máquinas.
* Se ha creado un volumen y se conectado a `controller`.

Una vez concluido nos muestra las direcciones IP flotantes:

    Outputs:

    Compute1 address = X.X.X.X
    Controller address = Y.Y.Y.Y

Si queremos eliminar la infraestructura creada:

	$ terraform destroy

## Configuración de la red

Para permitir la comunicación entre las máquinas de nuestro escenario,
hay que desactivar la configuración de los cortafuegos por interfaz
que automáticamente añade OpenStack, gestionando la extensión
`port-security` en todas las redes de nuestra infraestructura.

### Instalar nova-cli y neutron-cli

Voy a crear un entorno virtual, en mi puesto de trabajo, para instalar los clientes de openstack:

	$ apt-get install build-essential python-virtualenv python-dev libssl-dev libffi-dev

	$ virtualenv os
	$ source os/bin/activate
	(os)$ pip install requests python-novaclient python-neutronclient

Ejecutamos el siguiente script:

    $ source deshabilitar_grupos_seguridad.sh
	
Que siguiendo las siguientes
[instrucciones](https://wiki.openstack.org/wiki/Neutron/ML2PortSecurityExtensionDriver) 
(recordamos que debe estar habiliatado la extensión `port security`),
se encarga de quitar los grupos de seguridad y deshabilitar la
política antispoofing de OpenStack en cada interfaz de red.

También podríamos hacerlo manualmente mediante los siguientes pasos:

	nova remove-secgroup controller default
	nova remove-secgroup compute1 default

Y desactivar el flag `port_security_enabled` en los puertos
correspondientes a las interfaces de 'compute' y 'controller':

	neutron port-list
	...	
	| 908bf3ad-51de-4491-bb74-c35fde3c50dd |      | fa:16:3e:02:7a:31 | {"subnet_id": "0f726304-d638-49ef-8b2e-acf20bb95143", "ip_address": "10.0.1.10"}                             |
	| 652093ae-4c4a-4bac-9be4-ffad0c40d879 |      | fa:16:3e:4d:b0:4b | {"subnet_id": "0f726304-d638-49ef-8b2e-acf20bb95143", "ip_address": "10.0.1.11"}                             |
	| 1492dc89-2126-4e6b-aa84-ed4446660b2c |      | fa:16:3e:3f:38:00 | {"subnet_id": "b0242456-3da3-4f9a-9f32-3a657ec22ed7", "ip_address": "192.168.0.10"}                          |
	| b5ed6b30-564c-4682-a17e-6caed1797a8a |      | fa:16:3e:fd:a5:4f | {"subnet_id": "b0242456-3da3-4f9a-9f32-3a657ec22ed7", "ip_address": "192.168.0.11"}                          |
	...
	neutron port-update  <Port_id> --port-security-enabled=False

## Configuración de los nodos

Vamos a realizar esta configuración con la herramienta "fabric", por lo que en nuestro puesto de trabajo, necesitamos instalar [fabric](http://www.fabfile.org/):

	# apt-get install fabric

O de forma alternativa en un entorno virtual:

	$ virtualenv fabric
	$ source fabric/bin/activate
	(fabric)$ pip install appdirs pyparsing fabric  

A continuación ejecutamos la configuración de fabric (donde X.X.X.X es
la IP flotante asociada al nodo controlador y Y.Y.Y.Y la IP flotante asociada al nodo de computación):

	$ cd conf
	$ fab -H X.X.X.X,Y.Y.Y.Y main

El script realiza las siguientes tareas:

* Configura el /etc/hosts
* Actualiza el sistema
* Configura permisos de la clave privada
* Instala los paquetes necesarios

## Ejecución de la receta de ansible

Desde nuestro equipod e trabajo, clonamos el repositorio de instalación
de OpenStack sobre Ubuntu (en este caso la rama ocata):

	$ git clone -b ocata https://github.com/iesgn/openstack-ubuntu-ansible.git
	
Y lo ejecutamos:

	$ cd openstack-ubuntu-ansible
	$ ansible-playbook site.yml --sudo

