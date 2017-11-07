printf "\n" >> /home/vagrant/.bashrc
echo 'export PS1="\[\e[01;34m\]fiware-sdk\[\e[0m\]\[\e[01;37m\]:\w\[\e[0m\]\[\e[00;37m\]\n\\$ \[\e[0m\]"' >> /home/vagrant/.bashrc
printf "\n" >> /home/vagrant/.bashrc

# install dockers

sudo yum -y check-update
sudo yum -y install vim
sudo yum -y install emacs-nox git nmap net-tools
curl -fsSL https://get.docker.com/ | sh
curl https://gist.githubusercontent.com/danimaniarqsoft/177b6c8cb579f0cac87b8d13d74e886c/raw/cdbdd584defb996b570ec068388405ec2f017741/docker-compose.yml > docker-compose.yml
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker vagrant

# install dockers-composed

sudo yum install -y epel-release
sudo yum install -y python-pip
sudo pip install --upgrade pip
sudo pip install backports.ssl_match_hostname --upgrade
sudo pip install docker-compose
sudo yum -y upgrade python*

sudo yum clean all

# Por bug de vagrant se forza el inicio de la interface de red
[ $(ifconfig eth1 | grep inet | wc -l) = 0 ] && ifup eth1
sudo chmod +x /etc/rc.d/rc.local
sudo echo "[ $(ifconfig eth1 | grep inet | wc -l) = 0 ]" >> /etc/rc.d/rc.local


#Downloading configuration files for java, maven, and mongodb

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
git clone -b demo https://github.com/danimaniarqsoft/fiware-orion-subscriber.git
sudo chown -R vagrant:vagrant fiware-orion-subscriber
## Install Mongodb
sudo yum -y install mongodb-org
sudo systemctl start mongod
