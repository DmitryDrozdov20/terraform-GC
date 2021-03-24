# Ubuntu 20.04 image
FROM ubuntu:20.04
RUN apt update
RUN apt-get install wget -y
# Install Java
RUN apt-get install default-jdk -y
# Install Git
RUN apt-get install git -y
# Install maven
RUN apt-get install maven -y
# Clone from Git
WORKDIR /home/
RUN git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
WORKDIR /home/boxfuse-sample-java-war-hello/
# Build
RUN mvn package
# Start Tomcat9 and deploy webapp
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME
RUN wget https://apache-mirror.rbc.ru/pub/apache/tomcat/tomcat-9/v9.0.44/bin/apache-tomcat-9.0.44.tar.gz -O /tmp/tomcat.tar.gz
RUN cd /tmp && tar xvfz tomcat.tar.gz
RUN cp -Rv /tmp/apache-tomcat-9.0.44/* /usr/local/tomcat/
EXPOSE 8081
RUN cp /home/boxfuse-sample-java-war-hello/target/hello-1.0.war /usr/local/tomcat/webapps/
CMD ["catalina.sh", "run"]
