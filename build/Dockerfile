FROM mongo:4.0.4
RUN apt-get update && apt-get install -y \
                      net-tools \
                      netcat
RUN mkdir -p /data/db
COPY entry.sh add_user.sh entry_ssl.sh dummy /usr/bin/
RUN chmod a+x /usr/bin/entry.sh
ENTRYPOINT [ "/usr/bin/entry.sh" ]
EXPOSE 27017
