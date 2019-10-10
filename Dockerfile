FROM debian:buster-slim

COPY symvol.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/symvol.sh

RUN symvol.sh move


