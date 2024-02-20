FROM debian:buster-slim

ARG USERS
ENV USERS=${USERS}

ARG FRIENDS
ENV FRIENDS=${FRIENDS}

ARG MY_HOSTNAME
ENV MY_HOSTNAME=${MY_HOSTNAME}

COPY scripts/ /usr/local/bin/scripts/

RUN chmod +x /usr/local/bin/scripts/*

RUN /usr/local/bin/scripts/create-users.sh

RUN apt-get update && apt-get install -y \
    postfix \
    telnet \
    dovecot-pop3d \
    dovecot-core \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

COPY postfix/ /etc/postfix/
COPY dovecot/ /etc/dovecot/

RUN /usr/local/bin/scripts/mail-setup.sh

EXPOSE 25 110

CMD ["/usr/local/bin/scripts/startup.sh"]