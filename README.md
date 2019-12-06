# teloscoin-tor
docker container: Telos Coin masternode with Tor

Description and purpose:
This repository is a contribution as a resource to easily build a docker image and create a container that contains a hot TELOS Coin wallet configured to run as a masternode, transcendenced uses Tor to connect to the network for privacy and anonymity. Tor is also contained within the container making this an all-in-one solution using s6-init to run multiple processes in the same container. The linkage between transcendenced and the local Tor is configured on build of the image. All of the processes within the container have been set up to run as their proper non-privileged users. Tor runs as user debian-tor within the container and transcendenced runs as user transcendence. The image is based on ubuntu 16.04 and the Dockerfile will pull this image as a base on build.

<b>BUILD INFO</b><br>
Steps to install:<br>
clone the repository with git:<br>
<code>git clone https://github.com/taperj/teloscoin-tor</code><br>
Change directory to the root of the project:<br>
<code>cd teloscoin-tor</code><br>
<code>sudo ./install.sh</code><br>


torpassword in transcendence.conf is set to "decentralization" and should be changed to whatever you change the Tor controller password to in the follwing step. Note that you can build and use as is, it has been configured to work but it is highly suggested that you take the time to edit the Dockerfile and transcendence.conf changing the tor control password prior to build, or after build once the container is deployed. I have added the following instructions are in the Dockerfile to guide you:
     
#Hashed Password is "decentralization" change this with tor --hash-password \<yournewpassword\><br>
#and use the ouput to replace the following in /etc/tor/torrc. Make sure to also update transcendence.conf torpassword= with the<br>
#new password in plain text, not hashed.<br>
&&    echo "HashedControlPassword 16:C7F40C06065809EE60D5C0B9086D2BDF88F32495CD1AE06E4571CB8212" >> /etc/tor/torrc \

Make sure to allow port 8051/tcp in your hosts firewall(not within the container), this can usually be accomplished with:<br>
sudo ufw allow 8051/tcp<br>
<br>
<b>Relevant links:</b><br>
<b>S6-INIT:</b> https://skarnet.org/software/s6/ <br>
<b>Tor:</b> https://www.torproject.org/ <br>
<b>TELOS Coin:</b> https://teloscoin.org/ <br>
<b>Docker:</b> https://www.docker.com/ <br>
