# docker build -t willbe docker/debian
# docker run -it --rm willbe

FROM debian:stable

SHELL [ "/bin/bash", "-l", "-c" ]
ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
EXPOSE 8080
ADD . /willbe

RUN apt-get update
RUN apt-get install curl -y
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
RUN nvm install --lts
RUN cd /willbe

CMD [ "bash" ]
