# Ubuntu Dockerfile
# Installs the following - Java 8, Chrome, Git, NodeJs, NPM, Maven

# Pull base image.
FROM ubuntu:latest

LABEL version 1.0

# Set environment variables.
ENV HOME /root
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# Define working directory.
WORKDIR /tmp

ENTRYPOINT ["/tmp"]

# Define default command.
CMD ["mvn", "clean", "install", "-Dheadless=\"on\""]

# Expose ports.
EXPOSE 5901

ARG MAVEN_VERSION=3.5.4
ARG USER_HOME_DIR="/root"
ARG SHA=ce50b1c91364cb77efe3776f756a6d92b76d9038b0a0782f7d53acf1e997a14d
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN apt-get update
RUN apt-get install -y gnupg
RUN apt-get install -y --no-install-recommends locales
RUN apt-get dist-upgrade -y
RUN apt-get -y upgrade
RUN apt-get --purge remove openjdk*
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get update
RUN apt-get install -y --no-install-recommends oracle-java8-installer oracle-java8-set-default
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y git wget nodejs
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list
RUN apt-get update
RUN apt-get install -y google-chrome-stable
RUN mkdir -p /usr/share/maven /usr/share/maven/ref
RUN curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz
RUN echo "${SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c -
RUN tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1
RUN rm -f /tmp/apache-maven.tar.gz
RUN ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean all

COPY ./pom.xml /tmp
COPY ./src /tmp
COPY ./target /tmp

RUN cd /tmp

RUN mvn clean install -Dheadless="on"


