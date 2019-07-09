#!/bin/bash

groupadd -g 272 stunnel
useradd -u 272 -g stunnel -s /sbin/nologin -d /dev/null -c "Owner of Stunnel processes" stunnel

counter=0

for i in `rpm -q stunnel | grep stunnel | awk -F "-" '{print $1}'` ;
do
   ((counter+=1))
done

if [ ${counter} -ne 1 ]
then
   yum -y install stunnel
fi

mkdir /etc/stunnel/conf.d
mkdir /etc/stunnel/CA
mkdir /etc/stunnel/CRL

# SELinux part of the setup:

counter=0

for i in `rpm -q selinux-policy-devel | grep selinux | awk -F "-" '{print $1}'` ;
do
   ((counter+=1))
done

if [ ${counter} -ne 1 ]
then
   yum -y install selinux-policy-devel
fi

cp systemd/tmpfiles.d-stunnel.conf /usr/lib/tmpfiles.d/stunnel.conf

TMP=/tmp/`uuidgen`

mkdir ${TMP}

cp selinux/stunnel2log.te ${TMP}

pushd ${TMP}
make -f /usr/share/selinux/devel/Makefile
semodule -i stunnel2log.pp
popd

rm -fr ${TMP}

if [ ! -d "/var/log/stunnel" ]
then
   mkdir /var/log/stunnel
fi

chmod 750 /var/log/stunnel
chown stunnel:stunnel /var/log/stunnel
chcon -t stunnel_log_t /var/log/stunnel

cp systemd/stunnel@.service /usr/lib/systemd/system/

