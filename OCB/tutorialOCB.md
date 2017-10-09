# Gestión de información de contexto con Orion Context Broker

Nuestro objetvo final es hacer aplicaciones inteligentes que utilicen información obtenida de diferentes medios como sensores, usuarios de dispositivos móviles, etéctera. 

![](/Users/carlosaburto/Documents/1.ITAM/Servicio Social/Tutoriales/FIWARE/OCB/Imagenes/00SC.png)

Para que nuestra aplicación pueda obtener esa información utilizaremos Orion Context Broker (OCB). Orion Context Broker es una implementación de la API NGSI (*Next Generation Service Interface Context Enabler*) que te permite manejar y asegurar la disponibilidad de la información obtenido del contexto. 

Para representar objetos de la vida real utilizaremos el modelo de entidades de la API NGSI. En éste se define un **modelo de datos** de información de contexto basado en *entidades* y en *atributos*. Cada entidad representa un objeto de la vida real y puede tener atributos y metadatos. Las entidades cuentan con ID y tipo y los atributos y metadatos con nombre, tipo y valor. Todos los datos estarán representados con el formato JSON.  
Los metadatos son infromación de los atributos y se ponen con la misma estructura. 

Por ejemplo, modelaremos la temperatura y la presión de un cuarto con la siguiente entidad:

	{
		"id": "Cuarto1"
		"type": "Cuarto"
		"temperature": {
			"type": "Float",
			"value": 23,
			"metadata":{}
		},
		"pressure":{
			"type":"Integer",
			"value": 720
		}
	}
	

La interacción básica con el OCB consta de tres agentes: el productor de información de contexto, el context broker (CB) y el consumidor de esa información.

![](/Users/carlosaburto/Documents/1.ITAM/Servicio Social/Tutoriales/FIWARE/OCB/Imagenes/ngsi.png)

El productor de información de contexto se encargará de crear nuevas entidades o de actualizar las entidades ya existentes a través del puerto 1026.    
Los datos se mantendrán persistentes gracias al CB, que además funciona como intermediario entre los otros dos agentes. Éste solamente guardará el último dato que se ingresó por lo que para poderlos almacenar usremos MongoDB.  
El consumidor será el que obtenga la información del CB para su uso final también a través del puerto 1026. La obtención de la información se puede dar a través de consultas a la base de datos (querys)y por medio de notificaciones. 

Una característica muy importante es que para el OCB no importa de donde se está obteniendo la información, al final, la aplicación la recibirá igual. Así, toda la información que ulizaremos estará homogeneizada y podremos usarla facilmente.   

### Configuración de la máquina virtual
Se requiere tener instalado en la computadora:
	
* VirtualBox
* SSH
* Vagrant 1.9.0
* Git
* Insomnia


Vagrant es un versionador de máquinas virtuales con lo cual es muy fácil comenzar a hacer uso de ellas. 
Con esta herramienta crearemos una máquina virtual con el sistema operativo CentOs dentro del cual se instalará también docker, MongoDB y OCB. 
Para poder instalar la máquina virtual en nuestra computadora haremos los siguientes pasos:

```
# Utilizando la terminal. 
	#### Set up
	# crear carpeta
	mkdir curso
	# cambiar de directorio
	cd curso
	# bajar estructura de las máquinas virtuales
	git clone https://github.com/CarlosUrteaga/Fiware.git
	# Cambiar a directorio Fiware
	cd Fiware
	cd vm-fiware-orion
	# iniciar máquina virtual de Orion
	vagrant up
	# conectar a máquina virutal por medio de SSH
	vagrant ssh
	#iniciar docker de OCB
	docker-compose up
```
###Interactuando con OCB
La interacción con el OCB la haremos a través de solicitudes HTTP con un cliente REST.
Para poder hacerlo nececitamos especificar el URL al cual estaremos haciendo la solicitud, el método REST de la solicutud, el encabezado y el cuerpo de la solicitud.   
El URL al que haremos la solicitud sera: **http://localhost:1026/v2/...**. Aquí podemos ver, como se indicaba en el diagrama, que la comunicacion se hace a través del puerto 1026 y que la versión del OCB es la 2.  
Los métodos REST que utilizaremos son **GET, POST, PUT, DELETE, OPTIONS, HEAD, TRACE, CONNECT.**  
El encabezado indica en que formato se estará recibiendo y enviando la información. Si la información será de tipo JSON se debe poner **application/json** y si será de tipo texto se debe de poner **text/plain**.
Para referirse a que estarás enviando información se debe de poner **Content-Type** y para indicar que quieres recibir se debe de poner **Accept**.  

Así, una solicitud quedaría de la siguiente manera: 
 

```
xx.xx.xx:pto/v2/entities
Método: POST
Headers: Content-Type:application/json
Body:
{  “id”: xx
   “type”: xx
   “atributo”:{
   		"value":xx
   }
   ...
}
```



  
Para poder interactuar con OCB utilizaremos *insomnia*.  
Crearemos en insomnia una carpeta llamada **Operaciones-Comunes**. En esta carpeta se guardarán todas las consultas que hagamos. 

![](/Users/carlosaburto/Documents/1.ITAM/Servicio Social/Tutoriales/FIWARE/OCB/Imagenes/Insomnia/In-01.png)

####POST
En primer lugar hay que **crear** la entidad con el método **POST**:
Comenzaremos por crear una nueva petición en Insomnia

![](/Users/carlosaburto/Documents/1.ITAM/Servicio Social/Tutoriales/FIWARE/OCB/Imagenes/Insomnia/In-02.png)

El nombre sugerido para esta petición es **inserta-entidad**, el método que utilizaremos será **PUT** y el body será de tipo JSON.

![](/Users/carlosaburto/Documents/1.ITAM/Servicio Social/Tutoriales/FIWARE/OCB/Imagenes/Insomnia/In-03.png)  

Como habíamos mencionado antes nuestras peticiones se conforman por tres partes.  
En este caso el URL que utilizaremos será **http://localhost:1026/v2/entities**, el header se pone automaticamente cuando seleccionamos JSON como el tipo de dato y en el body pondremos:

```
{
		"id": "lugar01",
		"type": "ParkingSpot",
		"floor" :{
			"value":"PB",
			"type":"text"
	    },
		"name" :{
			"value":"A-13"
	    },
		"status" :{
			"value":"libre"
	    }
	}
```
	
#### GET
Para **obtener** todas las entidades que tenemos guardadas usaremos el método **GET**:

```
localhost:1026/v2/entities
Método: GET
```
En este caso no se especifican ni el body ni Content-type.  
No obstante si se está consultando un OCB en la nube, será necesario agregar en el campo X-Auth-Token el token que les fue asignado.

```
Headers X-Auth-Token	1O11Qj4FReeHTs0Rb5hVLYwKNHFbbu
```
Podemos también buscar una entidad en específico por medio de su ID, para lo cual tenemos que poner **/{id}** al final de nuestro URL.

```
Método: GET
{url}:1026/v2/entities/{id}
```
Así:

```
localhost:1026/v2/entities/lugar01
Método: GET
```

#### PUT y PATCH  
Podemos también **actualizar** una entidad.   
Una nueva convención a surgido para diferenciar los dos métodos existentes para actualizar. Si queremos actualizar una parte de la entidad se debe utilizar el método **PATCH** y si se quiere actalizar la entidad completa se debe de utilizar el método **PUT**, teniendo en cuenta que si no se especifican algunos atributos éstos deberían colocarse en nulo. En realidad muchas de las aplicaciones no toman en cuenta esta distinción y utilizan el método PUT como un sinónimo del método PATCH pero es importante conocer la diferencia.

```
Método: PUT
{url}:1026/v2/entities/{id}
```
```
Método: PATCH
{url}:1026/v2/entities/{id}/attrs/{value}/value
```
Así tenemos:

```
localhost:1026/v2/entities/lugar01
Método: PUT
Headers: Content-Type:application/json
Body;
{
		"id": "lugar01",
		"type": "ParkingSpot",
		"floor" :{
			"value":"PB",
			"type":"text"
	    },
		"name" :{
			"value":"A-13"
	    },
		"status" :{
			"value":"ocupado"
	    }
	}
```

```
localhost:1026/v2/entities/lugar01/attrs/status/value
Método: PATCH
Headers: Content-Type:text/plain
Body:
	"ocupado"
```
En ambos casos cambiando el valor de status por ocuapado. 

#### Delete
Este comando eliminará atributos y entidades. 
Para borrar una entidad se utiliza a siguiente expresión: 

```
{url}:1026/v2/entities/{id}
Método: DELETE
```

Y para borrar un atributo:

```
{url}:1026/v2/entities/{id}/attrs/{value}
Método: DELETE
```


Estas son las bases para hacer una aplicación que reciba su infromación de forma síncrona, pero el OCB tiene la capacidad de entregar información de fomra asincrona.
Esto se logra gracias a las suscripciones, las cuales envian una notificación asincrona al consumidor de información cuando se de un "evento". 
La suscripción está compuesta por 4 partes:

 - El tópico (subject) el cual tiene la entidad a la que quieres suscribirte, la condición y, dentro de ésta, el o los atributo que, al cambiar, provocarán el envío de la notificación. Puede cambiar uno o varios de los atributos de esta lista para provocar el envío de la notificación.  La lista puede estar vacía lo cual indicara que con el cambio de cualquiera de los atributos de la entidad se enviará la notificación.  
 - La notificación la cual contiene la dirección a la cual se enviará la notificaión y los atributos que se enviarán. 
 - La fecha en la que la suscripción terminará, la cual se puede escribir con el formato estándar de la ISO 8601.
 - El tiempo de espera (trhottling) para envíar una nueva notificación. 


Si por ejemplo quisieramos suscribirnos a un cambio de la presión en nuestro Cuarto1 y recibir la temperatura del mismo debemos hacer la suscripción de la siguiente manera: 

```
localhost:1026/v2/suscriptions
Body:
	{
		"subject":{
			"entities":[
			 	{
			 		"id":"Cuarto1",
			 		"type":"Cuarto"
			 	}
			 ],
			 "condition": {
			 	"attrs":[
			 		"pressure"
			 	]
			 }
		},
		"notification":{
			"http":{
				"url":"http://localhost:1028/accumulate"
			},
			"attrs":[
				"temperature"
			]
		},
		"expires":"2040-01-01T14:00:00.00Z",
		"throttling":5
	}
```

 







##################




### Metadatos
Los metadatos se agregan en la nueva versión de NGSI. Simplemente se pone información adicional con la misma estructura.  Por ejemplo, para temperatura, se podría agregar algo así:

	{
		"id":"Room-infotec-cd-MX-JCUR",
		"type":"Room",
		"temperature" :{
			"value":23,
			"metadata":{
				“precision”: {
    				“type”:xxx,
  					“value”: xxx
				}
			}
		...

##OCB Query Language

Para practicar con algunos de los comandos de OCB, primero poblaremos la BD con varias entidades.  Se pueden agregar las entidades una a una con el método POST, pero también es posible enviar un conjunto de entidades especificando un APPEND con el URL update:

```html
url .../v2/op/update

{
	"actionType":"APPEND",
	"entities":[
	{	"id": "Bedroom1",
		"type": "Room",
		"temperature": {
			"value": 27.8,
			"type": "float"
		},
		"presence": {
			"value": true,
			"type": "boolean"
		},
		"status": {
			"value": "OK",
			"type": "string"
		},
		"id": "Bedroom2",
		"type": "Room",
		"temperature": {
			"value": 27.8,
			"type": "float"
		},
		"presence": {
			"value": true,
			"type": "boolean"
		},
		"status": {
			"value": "OK",
			"type": "string"
		},
		"id": "Kitchen",
		"type": "Room",
		"temperature": {
			"value": 27.8,
			"type": "float"
		},
		"presence": {
			"value": true,
			"Type": "boolean"
		},
		"status": {
			"value": "OK",
			"type": "string"
		},
		"id": "Frontdoor",
		"type": "Door",
		"locked": {
			"value": false,
			"type": "boolean"
		},
		"closed": {
			"value": false,
			"type": "boolean"
		},
		"id": "Backdoor",
		"type": "Door",
		"locked": {
			"value": "false",
			"type": "boolean"
		},
		"closed": {
			"value": "false",
			"type": "boolean"
		}
	]
}
```

(Nota: FIWARE ya tiene un conjunto de metamodelos estandarizados, para no inventar el hilo negro.
Buscar en Google FIWARE data models (**fiware.org/data-models**)
Otra página muy importante es **schema.org**)

#### Parametrizar una consulta

Al realizar consultas, el OCB entrega únicamente 20 elementos por default.  Si se desea traler más, se agrega el parámetro `limit`al query. (En insomnia, se tiene una ventana especial para agregar los parámetros del query).

También se puede especificar el ofset a partir del cual se leerán los valores.

Asimismo, si no deseamos recibir la información en formato JSON, se puede especificar como opción *keyValues* como se muestra en el siguiente ejemplo:

```html
http://orion.lab.infotec.org:1026/v2/entities?limit=50&type=Room&options=keyValues
 ```

Con la propiedad *attrs* en el query, podemos recibir sólo la información de las propiedades que le especifique, por ejemplo, la temperatura.  Si queremos una consulta con valores específicos, se utiliza la opción *q* y la regla deseada.  El siguiente query entregaría los elementos en los que el atributo temperatura tiene un valor de 21.

```html
.../v2/entities?q=temperature=21&attrs=temperature
 ```
En los siguientes ejemplos se muestran consultas para un determinado tipo, para combinar varios identificadores, para elementos que coinciden con una expresión regular.
```
	?types=room
	idRooms1,Room2
	idPattern=^Room-MX-2[5-9]+|[3-9][0-9]

http://orion.lab.infotec.org:1026/v2/entities/Bedroom1/attrs
http://orion.lab.infotec.org:1026/v2/entities?id=Bedroom1,Kitchen

```

Los atributos virutales (para bitácoras) de *dateCreated* y *dateModified* también se pueden usar para filtrado

Si no usamos formato NGSI, podemos acceder a propiedades con notación punto.

```
q=tyrePressure.frontRight > 130
```
Queries más sofisticadas pueden hacerse con un texto de consultas donde se especifican campos en un formato json.

Para los queries sobre metadatos se utiliza la opcion **mq**. 

### Suscrpitores

La consulta de entidades en la nube la hacen los **consumidores**. Éstos son los que piden o escuchan datos de contexto.

Para recibir información por notificaciones, el consumidor debe suscribirse a un evento. Así podemos tener la aplicación en cualquier ambiente y con una suscripción al OCB la aplicación procesaría las notificaciones.

Para registrar el consumidor se usa:

```html
POST <ocb_host>:1026/v1/registry/registerContext

{
	“contextRegistrations”:[]
  	“entitites”:[
		“type”:xxx,
		“isPattern":"false”,
		“id”:xxx
	],
	“attributes”: [
    	...
    ]
	…
}
```

En la versión 2 se pueden solicitar notificaciones personalizadas:

```html
POST <ocb.host>:1026/v2/subscriptions
Content-Type: application/json

{
	“notification”:{
		“http”:{
			“url”:http://<host>:<port>/publish”
		},
		“attrs”:[“temperature”]
	},
	“expires”:”2017-….”
}
```

### Ejemplo de un suscriptor

Para las suscripciones, vamos a usar la otra máquina virtual (*consumer*)

Se nos proporcionó el siguiente archivo *init*, donde están los comandos para levantar esta VM:

```bash
#!/bin/bash

printf "\n" >> /home/vagrant/.bashrc
echo 'export PS1="\[\e[01;34m\]consumer\[\e[0m\]\[\e[01;37m\]:\w\[\e[0m\]\[\e[00;37m\]\n\\$ \[\e[0m\]"' >> /home/vagrant/.bashrc
printf "\n" >> /home/vagrant/.bashrc

sudo yum clean all
sudo yum -y update

# Downloading configuration files for java, maven, and mongodb

curl https://gist.githubusercontent.com/danimaniarqsoft/177b6c8cb579f0cac87b8d13d74e886c/raw/619c9e672496cddab49e92f44765a295b488ffb0/mongodb-org.repo > mongodb-org.repo
curl https://gist.githubusercontent.com/danimaniarqsoft/177b6c8cb579f0cac87b8d13d74e886c/raw/619c9e672496cddab49e92f44765a295b488ffb0/maven.sh > maven.sh
curl https://gist.githubusercontent.com/danimaniarqsoft/177b6c8cb579f0cac87b8d13d74e886c/raw/619c9e672496cddab49e92f44765a295b488ffb0/java.sh > java.sh


sudo mv mongodb-org.repo /etc/yum.repos.d/
sudo mv maven.sh /etc/profile.d/
sudo mv java.sh /etc/profile.d/

yum repolist

#  install the consumer server
## Install Java 8
curl -L -b "oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jdk-8u111-linux-x64.rpm -O
sudo yum -y localinstall jdk-8u111-linux-x64.rpm

### Crear liga java.csh
sudo ln -s /etc/profile.d/java.sh /etc/profile.d/java.csh

## Install Maven
curl http://www-us.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz > apache-maven-3.3.9-bin.tar.gz
sudo mv apache-maven-3.3.9-bin.tar.gz /opt
sudo tar xzf /opt/apache-maven-3.3.9-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.3.9 /opt/maven

source /etc/profile.d/maven.sh
source /etc/profile.d/java.sh
source /etc/profile.d/java.csh

## Install Git
sudo yum -y install git
git clone https://github.com/danimaniarqsoft/fiware-orion-subscriber.git
sudo chown -R vagrant:vagrant fiware-orion-subscriber
## Install Mongodb
sudo yum -y install mongodb-org
sudo systemctl start mongod
```

Dentro de la vm, entrar al directorio fiware-orion-subscriber. Ahí hay un archivo *pom.xml* donde se puede ver la configuración de algunos parámetros de la VM. Por ejemplo, la dirección y puerto donde se instala el consumidor es *192.168.83.2:8080*

Para levantar el consumidor, se ejecuta el comando  `mvn spring-boot:run`.  Podemos verificar que se ha levantado, porque tiene un tablero de control.

```bash
vagrant up
vagrant ssh
cd fiware-orion-subscriber

mvn spring-boot:run

# Desde un navegador, ejecutar:
http://192.168.83.2:8080/#/dashboard
```

La aplicación debe estar montada sobre un dominio.
Ahora modificamos el DNS interno del OCB para que pueda encontrar al consumidor. Eso se hace en el `docker-compose.yml`

```bash
#Dentro del host (orion)
#vagrant ssh

vi docker-compose.yml 

orion:
  image: fiware/orion
  links:
    - mongo
  ports:
    - "1026:1026"
  command: -dbhost mongo
  extra_hosts:
   - "consumer.fiware.infotec.mx:192.168.83.2"
mongo:
  image: mongo:3.2
  command: --nojournal
```
El registro de nuestro consumidor se hace con un POST al OCB.  El siguiente es un ejemplo para recibir notificaciones de temperatura.  Notar que las notificaciones se reciben en un endpoint http, donde está escuchando nuestro consumidor.

```bash
http://orion.fiware.infotec.mx:1026/v2/subscriptions

{
	"description": "Update average rating",
	"subject": {
		"entities": [
			{
				"id": "Room-infotec-cd-MX-jaid-3",
				"type": "Room"
			}
		],
		"condition": {
			"attrs": [
				"temperature"
			]
		}
	},
	"notification": {
		"httpCustom": {
			"url": "http://consumer.fiware.infotec.mx:8080/notifications",
			"headers": {
				"Content-Type": "text/plain"
			},
			"method": "POST",
			"qs": {
				"type": "${type}"
			},
			"payload": "The temperature is ${temperature} degrees"
		},
		"attrs": [
			"temperature"
		]
	},
	"expires": "2020-04-05T14:00:00.00Z",
	"throttling": 1
}
```
## Datos geo-referenciados
#####(8 de marzo de 2017)  

Para esta sección, el equipo de Infotec recabó una serie de datos georreferenciados de edificios en el Centro de la Ciudad de México, alrededor de Bellas Artes.  Subimos estos datos a nuestro OCB para poblar la base de datos. La forma en que se hizo esto fue con un POST update:


```html
post http://localhost:1026/v2/op/update
Body: json

{
  "actionType": "APPEND",
	"entities": [
		{
			"id": "Church-MX-1",
			"type": "PointOfInterest",
			"category": {
				"type": "Text",
				"value": "Church",
				"metadata": {}
			},
			"location": {
				"type": "geo:point",
				"value": "19.435433, -99.133072",
				"metadata": {}
			},
			"name": {
				"type": "Text",
				"value": "Catedral Metropolitana",
				"metadata": {}
			},
			"postalAddress": {
				"type": "StructuredValue",
				"value": {
					"addressCountry": "MX",
					"addressLocality": "México Ciudad de México",
					"addressRegion": "Ciudad de México"
				}
			},
			"source": {
				"type": "Text",
				"value": "http://www.arquidiocesismexico.org.mx",
				"metadata": {}
			}
		},
        ...
```

Podemos ver que la ubicación es del tipo *geo:point* que tiene como valor las coordenadas de longitud y latitud. Se pueden agregar otros datos como nombre, descripción, etc.

Para ver que se cargaron las entidades, invoquémosla con un GET:
```html
GET localhost:1026/v2/entitites
```

Ahora vamos a buscar puntos dentro de una figura geométrica. Usaremos las API de la Versión 1, en la que se usan queries de contexto. Para especificar puntos fuera de una circunferencia, el método es POST y el body tiene lo siguiente:

```html
POST localhost:1026/v1/queryContext

{
    "entities": [
        {
            "type": "PointOfInterest",
            "isPattern": "true",
            "id": ".*"
        }
    ],
	"attributes":[
		"location","name"
	],
    "restriction": {
        "scopes": [
            {
                "type": "FIWARE::Location",
                "value": {
                    "circle": {
                        "centerLatitude": "19.435513",
                        "centerLongitude": "-99.141194",
                        "radius": "170",
						"inverted":"false"
                    }
                }
            }
        ]
    }
}
```

Se está buscando cualquier elemento (id *) de “pointOfInterest”. En la sección de atributos, recibiría todos; aquí se está indicando que sólo se quiere recuperar el nombre.  

Las restricciones para la búsqueda son un círculo con cierto centro y radio (en metros).  
Inverted: true significa que recupere todos los que no están dentro del círculo.

Ahora hagamos un query de un polígono, el cual se forma así:

```
{
	"entities": [
		{
			"type": "PointOfInterest",
			"isPattern": "true",
			"id": ".*"
		}
	],
	"attributes": [
		"location",
		"name"
	],
	"restriction": {
		"scopes": [
			{
				"type": "FIWARE::Location",
				"value": {
					"polygon": {
						"vertices": [
							{
								"latitude": "19.436025",
								"longitude": "-99.141540"
							},
							{
								"latitude": "19.435900",
								"longitude": "-99.140652"
							},
							{
								"latitude": "19.434764",
								"longitude": "-99.140883"
							},
							{
								"latitude": "19.434936",
								"longitude": "-99.141929"
							}
						],
						"inverted": "false"
					}
				}
			}
		]
	}
}
```
El polígono se forma por un conjunto de vértices.  La figura debe ser cerrada.


#### Demo monitoreo ambiental
Al final de esta sección, el personal de Infotec hizo una demostración de una App que desarrollaron con CentroGeo y Cenidet para recuperar parámetros de contaminación ambiental desde un celular (capturando coordenadas geográficas) y enviarlo a la nube Fiware.

La app permite capturar nombre de estación, y en teoría llenaría campos de partículas, ozono, etc.  y la intención es que estaría desplazándose en un coche.  Hacen commit a la base de datos de centro geo y en tiempo real se muestran los puntos.

La dirección de la aplicación es `207.249.121.43/cdmx2/`










