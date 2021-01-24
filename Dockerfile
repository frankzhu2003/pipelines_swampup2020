#Download image from artifactory
ARG REGISTRY=docker.artifactory
#FROM openjdk:11-jdk
FROM $REGISTRY/docker/openjdk:11-jdk

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y nodejs \
    npm                       # note this one

WORKDIR /app

#Define ARG Again -ARG variables declared before the first FROM need to be declered again
#ARG REGISTRY=https://etrainning.jfrog.io
MAINTAINER Shani Levy

# Download artifacts from Artifactory
RUN curl https://etrainning.jfrog.io/artifactory/libs-release-local/com/jfrog/backend/1.0.10/backend-1.0.10.jar --output server1.jar
RUN curl https://etrainning.jfrog.io/artifactory/npm-local/frontend/-/frontend-1.0.5.tgz --output client1.tgz

#Extract vue app
RUN tar -xzf client1.tgz && rm client1.tgz

WORKDIR "package"

RUN npm install

RUN npm run build

# Set JAVA OPTS + Static file location
ENV STATIC_FILE_LOCATION="/app/package/target/dist/"
ENV JAVA_OPTS=""

# Fire up our Spring Boot app
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -Dspring.profiles.active=remote -Djava.security.egd=file:/dev/./urandom -jar /app/server1.jar" ]
