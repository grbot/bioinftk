#############################################################
# Dockerfile to build a container for bamcov
#############################################################

FROM ubuntu:18.04
MAINTAINER Gerrit Botha "gerrit.botha@uct.ac.za"

RUN apt-get -m update && apt-get install -y wget unzip zip \
libbz2-dev liblzma-dev libcurl4-openssl-dev zlib1g-dev \
git make gcc

RUN git clone --recurse-submodules https://github.com/fbreitwieser/bamcov

WORKDIR /bamcov

RUN make

RUN chmod +x bamcov

# Switch back to the ubuntu user so this tool (and the files written) are not owned by root
RUN groupadd -r -g 1000 ubuntu && useradd -r -g ubuntu -u 1000 -m ubuntu
USER ubuntu

WORKDIR /
ENV PATH /bamcov:$PATH
