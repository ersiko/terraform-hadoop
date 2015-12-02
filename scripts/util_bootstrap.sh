#!/bin/bash

# ensure the system is up to date
yum update -y

# install EPEL for Ansible support; then Ansible
wget -nv https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install epel-release-latest-7.noarch.rpm -y
yum install ansible -y



# install some stuff
yum install bind-utils nc telnet nmap ntp sysstat httpd zip unzip wget -y

# install system stress tool
curl "http://dl.fedoraproject.org/pub/epel/6/x86_64/stress-1.0.4-4.el6.x86_64.rpm" -o stress-1.0.4-4.el6.x86_64.rpm
yum install -y stress-1.0.4-4.el6.x86_64.rpm

# install the aws command line
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# install ambari and hdp dependencies
   # set open file limit
  echo "fs.file-max = 12288" >> /etc/sysctl.conf; sysctl -p
  # disable hugepages
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
  echo never > /sys/kernel/mm/transparent_hugepage/defrag
  # selinux permissive mode
  setenforce 0 # needed for Ambari setup to run; not persistent
  # set up ntp; default configuration will do
  systemctl enable ntpd.service; ntpdate pool.ntp.org; systemctl start ntpd.service
  # grab the java RPM from S3 and install
  /usr/local/bin/aws s3 cp s3://kpedsotherbucket/packages/jre-7u45-linux-x64.rpm jre-7u45-linux-x64.rpm
  yum install jre-7u45-linux-x64.rpm -y
  # grab the Ambari repo
  wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.1.2/ambari.repo -O /etc/yum.repos.d/ambari.repo
  # installation
  yum install ambari-server -y
  # configuration
  ambari-server setup -j /usr/java/default -s
  # startup
  nohup /etc/init.d/ambari-server start
 
# clean up
rm -rf awscli-bundle jre-7u45-linux-x64.rpm epel-release-latest-7.noarch.rpm
