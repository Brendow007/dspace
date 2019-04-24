﻿# This image will be published as dspace/dspace
# See https://dspace-labs.github.io/DSpace-Docker-Images/ for usage details
# 
# This version is JDK8 compatible
# - tomcat:7-jre8
# - ANT 1.10.5
# - maven:3-jdk-8
# - note: 
# - default tag for branch: dspace/dspace: dspace/dspace:dspace-5_x-jdk8

# Step 0 - Get postgres instance
# FROM dspace-postgres-educapes:latest as postgres




# Step 1 - Run Maven Build
FROM dspace/dspace-dependencies:dspace-5_x-jdk8 as build
ARG TARGET_DIR=dspace-installer
WORKDIR /app

# The dspace-install directory will be written to /install
RUN mkdir /install \ 
	&& chown -Rv dspace: /install

USER dspace

# RUN cat /usr/share/maven/ref/settings-docker.xml
# RUN cat /usr/share/maven/conf/settings.xml
# RUN /usr/share/tomcat7 ls
# RUN find / -name "*settings*.xml"
# RUN pwd
# COPY --chown=dspace src/main/docker/settings_docker.xml /usr/share/maven/ref/settings_docker.xml
# RUN cat /usr/share/maven/ref/settings-docker.xml


# Copy the DSpace source code into the workdir (excluding .dockerignore contents)
ADD --chown=dspace . /app/

# Copy proxy settings / comment it if you not use proxy.
COPY --chown=dspace src/main/docker/settings.xml /usr/share/maven/conf/settings.xml

# Copy build settings
COPY --chown=dspace src/main/docker/build.properties /app/build.properties

# Build DSpace.  Copy the dspace-install directory to /install.  Clean up the build to keep the docker image small
RUN mvn package && \
   mv /app/dspace/target/${TARGET_DIR}/* /install && \
   mvn clean

# Step 2 - Run Ant Deploy
FROM tomcat:7-jre8 as ant_build
ARG TARGET_DIR=dspace-installer
COPY --from=build /install /dspace-src
WORKDIR /dspace-src

# Create the initial install deployment using ANT
ENV ANT_VERSION 1.10.5
ENV ANT_HOME /tmp/ant-$ANT_VERSION
ENV PATH $ANT_HOME/bin:$PATH

RUN mkdir $ANT_HOME && \
    wget -qO- "https://www.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz" | tar -zx --strip-components=1 -C $ANT_HOME

RUN ant init_installation update_configs update_code update_webapps update_solr_indexes

# Step 3 - Run tomcat
# Create a new tomcat image that does not retain the the build directory contents
FROM tomcat:7-jre8

ENV DSPACE_INSTALL=/dspace
COPY --from=ant_build /dspace $DSPACE_INSTALL
EXPOSE 8080 8009

ENV JAVA_OPTS=-Xmx2000m

RUN ln -s $DSPACE_INSTALL/webapps/solr    /usr/local/tomcat/webapps/solr    && \
    ln -s $DSPACE_INSTALL/webapps/jspui   /usr/local/tomcat/webapps/jspui   && \
    ln -s $DSPACE_INSTALL/webapps/rest    /usr/local/tomcat/webapps/rest    && \
    ln -s $DSPACE_INSTALL/webapps/oai     /usr/local/tomcat/webapps/oai
    # ln -s $DSPACE_INSTALL/webapps/xmlui   /usr/local/tomcat/webapps/xmlui   && \
    # ln -s $DSPACE_INSTALL/webapps/rdf     /usr/local/tomcat/webapps/rdf     && \
    # ln -s $DSPACE_INSTALL/webapps/sword   /usr/local/tomcat/webapps/sword   && \
    # ln -s $DSPACE_INSTALL/webapps/swordv2 /usr/local/tomcat/webapps/swordv2
	