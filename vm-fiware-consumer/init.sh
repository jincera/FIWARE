#!/bin/bash

#!/bin/bash

printf "\n" >> /home/vagrant/.bashrc
echo 'export PS1="\[\e[01;34m\]consumer\[\e[0m\]\[\e[01;37m\]:\w\[\e[0m\]\[\e[00;37m\]\n\\$ \[\e[0m\]"' >> /home/vagrant/.bashrc
printf "\n" >> /home/vagrant/.bashrc

sudo yum clean all
sudo yum -y update

#Downloading configuration files for java, maven, and mongodb

curl https://gist.githubusercontent.com/danimaniarqsoft/177b6c8cb579f0cac87b8d13d74e886c/raw/619c9e672496cddab49e92f44765a295b488ffb0/mongodb-org.repo > mongodb-org.repo
curl https://gist.githubusercontent.com/danimaniarqsoft/177b6c8cb579f0cac87b8d13d74e886c/raw/619c9e672496cddab49e92f44765a295b488ffb0/maven.sh > maven.sh
curl https://gist.githubusercontent.com/danimaniarqsoft/177b6c8cb579f0cac87b8d13d74e886c/raw/619c9e672496cddab49e92f44765a295b488ffb0/java.sh > java.sh


sudo mv mongodb-org.repo /etc/yum.repos.d/
sudo mv maven.sh /etc/profile.d/
sudo mv java.sh /etc/profile.d/

yum repolist

#  install the consumer server


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
git clone https://github.com/carlosurteaga/fiware-orion-subscriber.git
sudo chown -R vagrant:vagrant fiware-orion-subscriber
## Install Mongodb
sudo yum -y install mongodb-org
sudo systemctl start mongod

#sudo yum -y install wget
sudo yum -y install wget

## Install Java 8
cd /opt/
BASE_URL_8=http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151
JDK_VERSION=`echo $BASE_URL_8 | rev | cut -d "/" -f1 | rev`
declare -a PLATFORMS=("-linux-x64.tar.gz")
for platform in "${PLATFORMS[@]}"
do
    wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "${BASE_URL_8}${platform}"
    ### curl -C - -L -O -# -H "Cookie: oraclelicense=accept-securebackup-cookie" "${BASE_URL_8}${platform}"
done
sudo tar xzf jdk-8u151-linux-x64.tar.gz

### Crear liga java.csh
sudo ln -s /etc/profile.d/java.sh /etc/profile.d/java.csh


export JAVA_HOME=/opt/jdk1.8.0_151
#export JRE_HOME=/opt/jdk1.8.0_144/jre
#export PATH=/opt/jdk1.8.0_144/bin:/opt/jdk1.8.0_144/jre/bin:$PATH

## Ejecutar al ingresar a la maquina virtual

# mvn -f fiware-orion-subscriber/pom.xml spring-boot:run
