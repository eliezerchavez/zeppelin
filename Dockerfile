FROM apache/zeppelin:0.9.0
LABEL MAINTAINER='Eliezer Efrain Chavez <eechavez@nttdata.com>'

ARG HADOOP_VERSION=2.7.7
ARG SPARK_VERSION=2.3.1

USER root

# HADOOP
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$HADOOP_HOME/lib/native
RUN curl -sL --retry 3 http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxvf - -C /opt \
 && chown -R root:root /opt/hadoop-${HADOOP_VERSION} && ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop

# SPARK
ENV SPARK_HOME /opt/spark
ENV SPARK_DIST_CLASSPATH $HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*
ENV PATH $PATH:$SPARK_HOME/bin
RUN curl -sL --retry 3 https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz | tar zxvf - -C /opt \
 && chown -R root:root /opt/spark-${SPARK_VERSION}-bin-without-hadoop && ln -s /opt/spark-${SPARK_VERSION}-bin-without-hadoop /opt/spark

USER 1000
