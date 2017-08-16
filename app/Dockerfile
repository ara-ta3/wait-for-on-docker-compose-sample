FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y make curl tar netcat-openbsd
RUN mkdir -p /opt
RUN curl https://raw.githubusercontent.com/Eficode/wait-for/master/wait-for > /opt/wait-for
RUN chmod +x /opt/wait-for
