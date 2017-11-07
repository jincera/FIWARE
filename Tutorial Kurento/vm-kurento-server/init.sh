# Instalar Kurento 
echo "deb http://ubuntu.kurento.org trusty kms6" | sudo tee /etc/apt/sources.list.d/kurento.list
wget -O - http://ubuntu.kurento.org/kurento.gpg.key | sudo apt-key add -
sudo apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install kurento-media-server-6.0 