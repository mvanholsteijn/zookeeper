FROM java:openjdk-7-jdk

ENV SERVICE_NAME zookeeper
ENV SERVICE_2181_TAGS zk

#
# TODO: these settings are not picked up by the zkServer.sh 
#
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

EXPOSE 2181

# create log4j log directory
RUN groupadd --system logging
RUN install -d --owner root --group logging --mode 0770 /var/log/log4j

# create zookeeper user
RUN groupadd --system zookeeper
RUN useradd --system -g zookeeper -G logging -s /bin/bash zookeeper
RUN install -d --owner zookeeper --group zookeeper --mode 0770 /home/zookeeper

#
# Set the TTL on
#
RUN sed -i -e 's/^#\?networkaddress.cache.ttl.*/networkaddress.cache.ttl=30/' \
        $(find /usr/lib/jvm -name java.security)

RUN apt-get update
RUN apt-get install -y bsdtar

RUN mkdir /opt/zookeeper && \
	curl -q http://ftp.nluug.nl/internet/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | \
	bsdtar -xopzf - -C /opt/zookeeper --strip-components 1

RUN install -d --owner zookeeper --group zookeeper --mode 0770 /var/lib/zookeeper/data /var/lib/zookeeper/data-log

USER zookeeper

ADD java.env /opt/zookeeper/conf/java.env
ADD zoo.cfg /opt/zookeeper/conf/zoo.cfg

ENTRYPOINT [ "/opt/zookeeper/bin/zkServer.sh", "start-foreground"]
