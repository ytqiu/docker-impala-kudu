#!/bin/bash
/wait-for-it.sh zookeeper:2181 -t 120
rc=$?
if [ $rc -ne 0 ]; then
  echo -e "\n----------------------------------------"
  echo -e "  ZooKeeper Server not ready! Exiting..."
  echo -e "----------------------------------------"
  exit $rc
fi

/wait-for-it.sh hadoop:8020 -t 120
rc=$?
if [ $rc -ne 0 ]; then
  echo -e "\n----------------------------------------"
  echo -e "  Hadoop Server not ready! Exiting..."
  echo -e "----------------------------------------"
  exit $rc
fi

cat etc/impala/conf/hive-site.xml|grep -A 1 hive.metastore.uris|grep value|awk -F">|<" '{print $3}'|awk -F"," '{for(i=1;i<=NF;i++)print $i}'|sed s/thrift:\\/\\///g|xargs -I {} /wait-for-it.sh {} -t 120
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n--------------------------------------------"
    echo -e "      Hive Metastore not ready! Exiting..."
    echo -e "--------------------------------------------"
    exit $rc
fi

#/start-kudu.sh


########################################
#	IMPALA
########################################
echo ${KUDU_MASTERS:=kudu-master:7051}|awk -F"," '{for(i=1;i<=NF;i++)print $i}'|xargs -I {} /wait-for-it.sh {} -t 120
rc=$?
if [ $rc -ne 0 ]; then
    echo -e "\n---------------------------------------"
    echo -e "     Kudu Masters not ready! Exiting..."
    echo -e "---------------------------------------"
    exit $rc
fi

/start-impala.sh
