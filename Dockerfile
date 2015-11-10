#| |        | |        (_)    | |       | |                  
#| | ___   _| |__  _ __ _  ___| | _____ | | ___   __ _ _   _ 
#| |/ / | | | '_ \| '__| |/ __| |/ / _ \| |/ _ \ / _` | | | |
#|   <| |_| | |_) | |  | | (__|   < (_) | | (_) | (_| | |_| |
#|_|\_\\__,_|_.__/|_|  |_|\___|_|\_\___/|_|\___/ \__, |\__, |
#                                                 __/ | __/ |
# Bob van Luijt (www.kubrickolo.gy)  		 |___/ |___/ 

##
# Build on Ubuntu 14.04
##
FROM ubuntu:14.04

##
# Maintainer is Bob van Luijt
##
MAINTAINER Bob van Luijt <bob@foobar.computer>

##
# Install software properties for running things like apt-add-repository
##
RUN apt-get update && \
	apt-get install software-properties-common python-software-properties -qq -y

##
# Install Java
# Note: 'echo debconf ***' is used for skipping licence accepting (Docker will fail otherwise)
##
RUN apt-add-repository ppa:webupd8team/java -y && \
	apt-get update && \
	apt-get install -qq -y debconf-utils && \
	echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
	echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
	apt-get install -qq -y oracle-java7-installer git

##
# Install mave 3.3.3
##
RUN wget http://mirrors.sonic.net/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz && \
	tar -zxf apache-maven-3.3.3-bin.tar.gz && \
	cp -R apache-maven-3.3.3 /usr/local && \
	ln -s /usr/local/apache-maven-3.3.3/bin/mvn /usr/bin/mvn

##
# Install Skala
##
RUN cd .. && \
	wget http://www.scala-lang.org/files/archive/scala-2.11.7.deb && \
	sudo dpkg -i scala-2.11.7.deb && \
	sudo apt-get update && \
	sudo apt-get install -qq -y scala

##
# Install hadoop eco system
##
RUN wget http://d3kbcqa49mib13.cloudfront.net/spark-1.2.0-bin-hadoop2.4.tgz && \
	tar -xzvf spark-1.2.0-bin-hadoop2.4.tgz
	#cd spark-1.2.0-bin-hadoop2.4/ && \
	#./bin/spark-shell > exit && \
	#cd ..

##
# Install Zeppelin
# Note: also installs nodejs and npm
# Note: Uses different Gruntfile (without Karma) for installation
##
RUN git clone https://github.com/apache/incubator-zeppelin.git && \
	cd incubator-zeppelin/ && \
	apt-get install npm nodejs -y && \
	ln -s `which nodejs` /usr/bin/node && \
	npm install -g grunt-cli && \
	export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=256m" && \
	wget -q https://raw.githubusercontent.com/kubrickology/Docker-Apache-Zeppelin/master/Zeppelin-Gruntfile.js -O zeppelin-web/Gruntfile.js && \
	mvn install -DskipTests

##
# Explose the correct ports
##
EXPOSE 8080 8081

##
# Start the deamon
##
CMD bin/zeppelin-daemon.sh start
