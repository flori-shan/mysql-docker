FROM mysql:8.0.14

COPY ensure-upgrade.sh /

VOLUME /etc/mysql

ENTRYPOINT "/ensure-upgrade.sh"
