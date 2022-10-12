##################################################################################################
# The following .dockerfile can be used as a docker image for the following repo # https://github.com/brian1917/workloader
# Published Docker image can be used from Dockerhub # ansred/ubuntu-workloader-ssh # https://hub.docker.com/repository/docker/ansred/ubuntu-workloader-ssh
# This docker file will use Ubuntu AMD64 image and install all utility packages, inlcuding OpenSSH Server to access to the server # user= testuser # password=testpassword and port exposed 22
# You can build this dockerfile (Make sure to change credentials used for OpenSSH 
# Make sure to edit pce.yaml as well with your Workloader information of simply used pce-add command
# Tip # You can use to test the dockerhub test image # https://labs.play-with-docker.com/
# Just run # "docker run -d -p 2022:22 --name workloader-ssh ansred/ubuntu-workloader-ssh"
# Note this flag if you wish delete the container when it stops --rm "docker run --rm -d -p 2022:22 --name workloader-ssh ansred/ubuntu-workloader-ssh"
# Example ssh -p 2022 testuser@10.0.12.201
# This dockerfile will automatically downloaded the latest linux repo for workloader from github and extract it for you to use at # /var/workloader/linux/linux-v8.24.6
# To build this Dockerfile # docker build -t ansred/ubuntu-workloader-ssh . --no-cache=true
# To push this Docker image # docker push ansred/ubuntu-workloader-ssh
# Maintainer Anas Hamra | anas.hamra@gmail.com
##################################################################################################
#image ansred/ubuntu-workloader-ssh
#!/bin/bash
FROM amd64/ubuntu

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y byobu curl git htop man zip unzip vim wget nano sudo openssh-server sshpass iputils-ping telnet traceroute

RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1000 testuser
RUN echo 'testuser:testpassword' | chpasswd
RUN service ssh start

EXPOSE 22

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive
#################################################
#Create directory for Workloader linux
RUN cd /var
RUN mkdir /var/workloader
RUN mkdir /var/workloader/linux

RUN cd /var/workloader/linux && curl https://api.github.com/repos/brian1917/workloader/releases/latest | grep "browser_download_url.*linux.*.zip" | cut -d ':' -f 2,3 | tr -d \" | wget -O workloader-linux.zip -qi -
RUN cd /var/workloader/linux && unzip workloader-linux.zip
RUN cd /var/workloader/linux/linux*
RUN cd /var/workloader/linux/linux* && ./workloader version
RUN chmod -R 777 /var/workloader/linux

CMD ["/usr/sbin/sshd","-D"]
##################################################################################################
