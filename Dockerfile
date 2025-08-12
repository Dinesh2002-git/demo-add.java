FROM ubuntu:latest

# Set environment variables
ENV CATALINA_HOME=/opt/tomcat
ENV PATH="$CATALINA_HOME/bin:$PATH"

WORKDIR /opt

# Install required packages
RUN apt-get update -y && \
    apt-get install -y wget unzip curl openjdk-17-jdk && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Tomcat
RUN wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.108/bin/apache-tomcat-9.0.108.tar.gz && \
    tar xvf apache-tomcat-9.0.108.tar.gz && \
    mv apache-tomcat-9.0.108 tomcat && \
    rm apache-tomcat-9.0.108.tar.gz

# Remove IP restrictions from Manager and Host Manager
RUN sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/d' /opt/tomcat/webapps/manager/META-INF/context.xml && \
    sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/d' /opt/tomcat/webapps/host-manager/META-INF/context.xml

# Increase WAR upload size to 1GB
RUN sed -i 's/<Connector port="8080"/<Connector port="8080" maxPostSize="1048576000"/' /opt/tomcat/conf/server.xml

# Create Tomcat admin user (manager access)
RUN sed -i '/<\/tomcat-users>/i \
<role rolename="manager-gui"/>\n\
<role rolename="admin-gui"/>\n\
<user username="admin" password="admin123" roles="manager-gui,admin-gui"/>' /opt/tomcat/conf/tomcat-users.xml

# Download sample.war and place in webapps
RUN wget https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war -O /opt/tomcat/webapps/sample.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]


