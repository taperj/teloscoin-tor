FROM ubuntu:18.04

RUN apt-get update \
	&&    apt-get install curl wget unzip -y \
	&&    curl --fail --silent -L https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz | tar xzvf - -C / \
	&&    apt-get install -y sudo tor stubby proxychains4 \
	&&    apt-get -y upgrade \
	&&    mkdir -v /home/debian-tor \
	&&    chown -v debian-tor:debian-tor /home/debian-tor \
	&&    chmod -v 750 /home/debian-tor \
	&&    wget https://github.com/phoenixkonsole/transcendence/releases/download/v2.0.0.1/Linux.zip \
	&&    unzip Linux.zip \
	&&    rm -vrf transcendence-qt \
	&&    chmod 755 transcendence* \
	&&    mv -v transcendence* /usr/bin \
	&&    rm -vrf Linux.zip \
	&&    useradd -s /usr/sbin/nologin -m -d /home/transcendence transcendence \
	&&    export CONF_DIR=/home/transcendence/.transcendence \
	&&    mkdir -v $CONF_DIR \
	&&    ln -s $CONF_DIR /root/.transcendence \
	&&    wget https://github.com/phoenixkonsole/transcendence/releases/download/v2.0.0.0/Bootstrap.zip \
	&&    unzip -d $CONF_DIR Bootstrap.zip \
	&&    rm -vrf Bootstrap.zip \
	&&    chown -vR transcendence:transcendence $CONF_DIR \
	&&    echo "Setting up /etc/tor/torrc" \
	&&    echo "User debian-tor" >> /etc/tor/torrc \
	&&    echo "DataDirectory /home/debian-tor/.tor" >> /etc/tor/torrc \
	&&    echo "HiddenServiceDir /home/debian-tor/.torhiddenservice/" >> /etc/tor/torrc \
	&&    echo "HiddenServicePort 8051 127.0.0.1:8051" >> /etc/tor/torrc \
	# Hashed Password is "decentralization" change this with tor --hash-password <yournewpassword> 
	# and use the ouput to replace the following in /etc/tor/torrc. Make sure to also update transcendence.conf torpassword= with the 
        # new password in plain text, not hashed.
	&&    echo "HashedControlPassword 16:C7F40C06065809EE60D5C0B9086D2BDF88F32495CD1AE06E4571CB8212" >> /etc/tor/torrc \
	&&    echo "ControlPort 9051" >> /etc/tor/torrc \
	&&    echo "Done setting up torrc." \
	&&    echo "This may take a moment..."

COPY ./services /etc/services.d/
COPY --chown=transcendence:transcendence transcendence.conf /home/transcendence/.transcendence/
COPY --chown=root:root stubby.yml /etc/stubby/
COPY --chown=root:root proxychains.conf /etc/
ENTRYPOINT [ "/init" ]
