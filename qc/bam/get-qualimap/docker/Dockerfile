#############################################################
# Dockerfile to build a container for QUalimap
#############################################################

FROM ubuntu:18.04
MAINTAINER Gerrit Botha "gerrit.botha@uct.ac.za"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -m update && apt-get install -y wget \
unzip \
openjdk-8-jre \
zip \
r-base \
libxml2-dev \
libcurl4-openssl-dev

RUN wget -q https://bitbucket.org/kokonech/qualimap/downloads/qualimap_v2.2.zip

RUN unzip qualimap_v2.2.zip && \
    rm qualimap_v2.2.zip

RUN chmod +x /qualimap_v2.2/qualimap

# Switch back to the ubuntu user so this tool (and the files written) are not owned by root
RUN groupadd -r -g 1000 ubuntu && useradd -r -g ubuntu -u 1000 -m ubuntu
USER ubuntu
WORKDIR /
ENV PATH /qualimap_v2.2:$PATH
