#############################################################
# Dockerfile to build a container for BAMStats
#############################################################

FROM ubuntu:18.04
MAINTAINER Gerrit Botha "gerrit.botha@uct.ac.za"

RUN apt-get -m update && apt-get install -y wget unzip openjdk-8-jre zip

RUN wget -q http://downloads.sourceforge.net/project/bamstats/BAMStats-1.25.zip

RUN unzip BAMStats-1.25.zip && \
    rm BAMStats-1.25.zip

# Switch back to the ubuntu user so this tool (and the files written) are not owned by root
RUN groupadd -r -g 1000 ubuntu && useradd -r -g ubuntu -u 1000 -m ubuntu
USER ubuntu
WORKDIR /BAMStats-1.25
