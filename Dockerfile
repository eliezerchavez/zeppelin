FROM ubuntu:focal
LABEL MAINTAINER='Eliezer Efrain Chavez <eechavez@nttdata.com>'

RUN apt-get update \
 && apt-get install -y locales \
 && dpkg-reconfigure -f noninteractive locales \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update \
 && apt-get install -y curl unzip \
    python3 python3-pip \
 && pip install py4j \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# JAVA
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# HADOOP
ENV HADOOP_VERSION 2.7.7
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$HADOOP_HOME/lib/native
RUN curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | tar zxvf - -C /usr/ \
 && rm -rf $HADOOP_HOME/share/doc \
 && chown -R root:root $HADOOP_HOME

# SPARK
ENV SPARK_VERSION 2.3.1
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -sL --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | tar zxvf - -C /usr/ \
 && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
 && chown -R root:root $SPARK_HOME

# WORKDIR $SPARK_HOME
# CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]

ARG gid=1000
ARG uid=1000

ARG SCALA_VERSION=2.11
ARG TZ=America/New_York


ENV ZEPPELIN_HOME=/opt/zeppelin
ENV ZEPPELIN_CONF_DIR $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR $ZEPPELIN_HOME/notebook
ENV ZEPPELIN_PORT 8080

RUN groupadd -g ${gid} zeppelin \
 && useradd -g ${gid} -m -u ${uid} zeppelin

# https://zeppelin.apache.org/docs/latest/setup/basics/how_to_build.html
RUN apt-get update && apt-get install -y git \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
 && dpkg-reconfigure --frontend noninteractive tzdata \
 && mkdir -p ${ZEPPELIN_HOME} && chown -R zeppelin:zeppelin ${ZEPPELIN_HOME}

RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz | tar zxvf - -C /opt \
 && ln -s /opt/apache-maven-3.8.1 /opt/maven \
 && cp /opt/maven/conf/settings.xml /opt/maven/conf/settings.xml.orig \
 && sed -i $(sed -n '/<mirror>/ =' /opt/maven/conf/settings.xml | tail -n 1)' s/<mirror>/<!--mirror>/' /opt/maven/conf/settings.xml \
 && sed -i $(sed -n '/<\/mirror>/ =' /opt/maven/conf/settings.xml | tail -n 1)' s/<\/mirror>/<\/mirror-->/' /opt/maven/conf/settings.xml \
 && ln -s /opt/maven/bin/mvn /usr/local/bin/mvn && ln -s /opt/maven/bin/mvnDebug /usr/local/bin/mvnDebug && ln -s /opt/maven/bin/mvnyjp /usr/local/bin/mvnyjp

USER zeppelin

# https://zeppelin.apache.org/docs/latest/setup/basics/how_to_build.html#build-profiles
RUN mkdir ~/source && git clone https://github.com/apache/zeppelin.git ~/source \
 && cd ~/source && MAVEN_OPTS="-Xmx2g" mvn clean package -DskipTests -Pbuild-distr -Pscala-2.11 -Pweb-angular \
 && cp -r zeppelin-distribution/target/zeppelin-*/zeppelin-*/* ${ZEPPELIN_HOME} \
 && mkdir -p ${ZEPPELIN_HOME}/logs && mkdir -p ${ZEPPELIN_HOME}/run \
 && rm -fr ~/source

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

WORKDIR ${ZEPPELIN_HOME}

CMD ["bin/zeppelin.sh"]
