#!/bin/bash
#
if [[ "$(\grep 'Ubuntu 16.04' /etc/lsb-release 2>/dev/null)" ]]
then
    apt update
    apt upgrade -y
    apt install python-pip -y
fi
#
if [[ "$(\grep 'CentOS Linux release 7' /etc/centos-release 2>/dev/null)" ]]
then
    yum install python-devel -y
    curl -LR --connect-timeout 10 https://bootstrap.pypa.io/get-pip.py | python
fi
#
pip install awscli
