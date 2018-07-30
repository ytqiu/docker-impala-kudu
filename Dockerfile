FROM parrotstream/centos-openjdk

MAINTAINER Matteo Capitanio <matteo.capitanio@gmail.com>

USER root

#RUN mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
#RUN mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
#RUN wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
#RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
#RUN wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#RUN wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#RUN yum makecache


ADD cloudera-impala-kudu.repo /etc/yum.repos.d/
ADD cloudera-cdh5.repo /etc/yum.repos.d/
RUN rpm --import https://archive.cloudera.com/beta/impala-kudu/redhat/7/x86_64/impala-kudu/RPM-GPG-KEY-cloudera
RUN rpm --import https://archive.cloudera.com/cdh5/redhat/5/x86_64/cdh/RPM-GPG-KEY-cloudera
#RUN yum install -y hadoop-libhdfs
RUN yum install -y impala-kudu impala-kudu-server impala-kudu-shell impala-kudu-catalog impala-kudu-state-store
RUN yum install -y gcc python-devel cyrus-sasl*
RUN yum clean all

ADD etc/supervisord.conf /etc/
ADD etc/default/impala /etc/default/
ADD etc/default/conf/hdfs-site.xml /etc/impala/conf/
ADD etc/default/conf/core-site.xml /etc/impala/conf/
ADD etc/default/conf/hive-site.xml /etc/impala/conf/

RUN mkdir /var/run/hdfs-sockets/ -p
RUN touch /var/run/hdfs-sockets/dn

WORKDIR /

# Various helper scripts
ADD bin/start-impala.sh /
ADD bin/supervisord-bootstrap.sh /
ADD bin/wait-for-it.sh /
RUN chmod +x ./*.sh

# Impala Ports
EXPOSE 21000 21050 22000 23000 24000 25010 26000 28000

##########################
# Kudu Ports
##########################
EXPOSE 8050 7050 8051 7051

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
