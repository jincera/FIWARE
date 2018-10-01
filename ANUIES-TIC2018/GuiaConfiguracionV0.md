# Taller Fiware - Smart Campus - Guía de instalación de componentes

#### Encuentro ANUIES-TIC 2018

## Introducción

(Los tutoriales para empezar a trabajar con Fiware se encuentran en: [https://fiware-tutorials.readthedocs.io/en/latest/](https://fiware-tutorials.readthedocs.io/en/latest/))

Tenemos tres opciones para trabajar con los componentes de Fiware:

1. Instalándolos localmente en máquinas virtuales con ayuda de contenedores.  
2. Instalándolos en un servidor 
3. Accediendo a instancias de los componentes en el ambiente de desarrollo Fiware Lab Cloud

En este documento se muestra cómo instalar localment los componentes de Fiware.

## 1. Componentes de Fiware en equipo local

#### Requerimientos de equipo

- Memoria 8 GB o 12 GB si es Windows (para la virtualización)

- Espacio en disco duro  16 GB (para las máquinas virtuales)

#### Requerimientos de software

- [Docker y Docker compose](https://docs.docker.com/)

- Un cliente REST, por ejemplo, [Insomnia](https://insomnia.rest/)

### 1.1 Instalación de Docker

En esta guía se muestra la instalación de docker en un ambiente Windows 10 siguiendo las instrucciones de [esta página](https://docs.docker.com/docker-for-windows/).  La guía instalación para MAC se encuentra [aquí](https://docs.docker.com/docker-for-mac/) y la de Linux, [aquí](https://docs.docker.com/install/).

Si su computadora no cumple los requerimientos para instalar docker directamente, instalamos [su toolbox](https://docs.docker.com/toolbox/overview/). 

Una vez instalado el toolbox, abrimos su terminal y verificamos que se haya instalado correctamente ejecutando el comando `docker --version`:

```bash
> docker --version
   Docker version 18.03.0-ce, build 0520e24302
```


La primera vez que se instala docker, es común verificar que todo funciona correctamente instalando la imagen "[Hello World](https://hub.docker.com/r/library/hello-world/)" del repositorio de contenedores Docker Hub, y ejecutándolo:

```bash
> docker run hello-world

   docker : Unable to find image 'hello-world:latest' locally
   ...
   
   latest:
   Pulling from library/hello-world
   ca4f61b1923c:
   Pulling fs layer
   ca4f61b1923c:
   Download complete
   ca4f61b1923c:
   Pull complete
   Digest: sha256:97ce6fa4b6cdc0790cda65fe7290b74cfebd9fa0c9b8c38e979330d547d22ce1
   Status: Downloaded newer image for hello-world:latest
   
   Hello from Docker!
   This message shows that your installation appears to be working correctly.
   ...
```



### 1.3 Instalación de los contenedores para Orion Context Broker

Como se verá en la práctica, el componente central de Fiware, es el [Orion Context Broker](https://fiware-orion.readthedocs.io/en/latest/) (OCB), que utiliza una base de datos de software libre  [MongoDB](https://www.mongodb.com/) para asegurar la persistencia de los datos que recibe e información adicional.   Por ello, debemos descargar dos imágenes de Docker y crear la interconexión entre ellos.  

Empezamos por recuperar las imágenes del Docker Hub y definir una red para interconectar los contenedores.  No utilizaremos un archivo de configuración *.yaml para familiarizarnos con algunos de los comandos de Docker. 

* Desde una terminal (o desde la terminal del toolbox si así lo instaló), ejecute:

```bash
$ docker pull mongo:3.6
$ docker pull fiware/orion
$ docker network create fiware_default
```

* El contenedor Docker con MongoDB se inicializa y se conecta a la red con los siguientes comandos: 

```bash
$ docker run -d --name=mongo-db --network=fiware_default --expose=27017 mongo:3.6 --bind_ip_all --smallfiles
```

* El OCB se inicializa y se conecta a la red así:

```bash
$ docker run -d --name=fiware-orion -h orion --network=fiware_default -p 1026:1026  fiware/orion -dbhost mongo-db
```
Si todo se ha instalado correctamente, deberá haber generado algunos mensajes como los siguientes:

![InstalaContenedores](https://i.imgur.com/iCw0QCR.jpg)

**Nota:** Si desea  borrar todo e iniciar de nuevo, puede ejecutar los siguientes comandos: 

```bash
$ docker stop fiware-orion docker 
$ rm fiware-orion 
$docker stop mongo-db 
$ docker rm mongo-db 
$ docker network rm fiware_default
```

* Verificamos que el sevidor está activo consultando la versión del OCB en el puerto 1026, que es donde espera las solicitudes de servicio. 
  Esto se puede hacer ejecutandoel comando `curl -X GET 'http://localhost:1026/version'`, invocando el URL en un navegador Web, o con nuestro cliente REST: 

![ocb-version](https://i.imgur.com/vmDPzGq.jpg)

Si todo está correcto, obtendrá una respuesta en el panel del extremo derecho de Insomnia:

```json
{
    "orion": {
        "version": "1.15.0-next",
        "uptime": "0 d, 0 h, 3 m, 21 s",
        "git_hash": "e2ff1a8d9515ade24cf8d4b90d27af7a616c7725",
        "compile_time": "Wed Apr 4 19:08:02 UTC 2018",
        "compiled_by": "root",
        "compiled_in": "2f4a69bdc191",
        "release_date": "Wed Apr 4 19:08:02 UTC 2018",
        "doc": "https://fiware-orion.readthedocs.org/en/master/"
    }
}
```

* **Nota:** En Windows, quizás deba utilizar la dirección privada que reportó docker al instalarse, por ejemplo:  http://192.168.99.100:1026/version


