#--------------------------------------------------------------------------------------------------
# Para servidor

# Instalar Kurento 
echo "deb http://ubuntu.kurento.org trusty kms6" | sudo tee /etc/apt/sources.list.d/kurento.list
wget -O - http://ubuntu.kurento.org/kurento.gpg.key | sudo apt-key add -
sudo apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install kurento-media-server-6.0

#--------------------------------------------------------------------------------------------------
#Para cliente

# Install Git 
sudo apt-get update
sudo apt-get -y install git 

# Install Maven 
sudo apt-cache search maven
sudo apt-get -y install maven

#Install Java
sudo apt-get -y install openjdk-7-jdk openjdk-7-doc openjdk-7-jre-lib

# Install NodeJS y Bower
curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get -y install nodejs
sudo npm install -g bower 