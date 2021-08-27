#!/usr/bin/env bash
trap exit SIGINT SIGTERM
clear

## This is README automated as script

# For various reasons run installer.sh as nonroot and switch to sudo as needed
[ "$(id -u)" == 0 ] && echo -e "\nSwitch to nonroot _airflow user, exiting\n" && exit 1

echo -e "\nSetting www proxy\n"
export HTTP_PROXY="http://myproxy:8080"
export HTTPS_PROXY="http://myproxy:8080"
export http_proxy="${HTTP_PROXY}"
export https_proxy="${HTTPS_PROXY}"
export no_proxy="localhost,*.net"
export PATH=${PATH}:/usr/local/bin

echo -e "\nInstall Salter Open Source IAC installer per https://github.com/saltstack-formulas/salter README\n"
CENTOS_VERSION7_HACK=$( rpm -E %{rhel} 2>/dev/null )  # centos7 technical debt
(( $? == 0 )) && (( CENTOS_VERSION7_HACK == 7 )) && export SALT_VERSION='stable 3001'
curl -LO https://raw.githubusercontent.com/saltstack-formulas/salter/master/go.sh && bash go.sh
if (( $? > 0 ));then
    echo -e "\nSee TROUBLESHOOTING section in README for known CentOS7 fixes"
    echo -e "\nOtherwise problem issue: https://github.com/saltstack-formulas/salter/issues"
    exit 11
fi

echo -e "\nSetting some variables\n"
IAC_CFG_DIR=/srv/pillar/saltstack-formulas
IAC_RUN_DIR=/srv/salt/namespaces/saltstack-formulas

echo -e "\nHandling salter.sh technical debt: https://github.com/saltstack-formulas/salter/issues/84\n"
sudo ln -s ${IAC_RUN_DIR}/airflow-formula/airflow     /srv/salt/airflow 2>/dev/null
sudo ln -s ${IAC_RUN_DIR}/rabbitmq-formula/rabbitmq   /srv/salt/rabbitmq 2>/dev/null
sudo ln -s ${IAC_RUN_DIR}/postgres-formula/postgres   /srv/salt/postgres 2>/dev/null
sudo ln -s ${IAC_RUN_DIR}/redis-formula/redis         /srv/salt/redis 2>/dev/null
sudo ln -s ${IAC_RUN_DIR}/hostsfile-formula/hostsfile /srv/salt/hostsfile 2>/dev/null
sudo rm -f ${IAC_CFG_DIR}/* /srv/salt/top.sls 2>/dev/null
sudo rm ~/go.sh ~/salter.sh 2>/dev/null

echo -e "\nPreparing IAC Configuration .. very important\n"
CFG_DIR=~/airflow-component
sudo cp ${CFG_DIR}/config.* ${IAC_CFG_DIR}/ || exit 2
sudo cp ${CFG_DIR}/installer.sls /srv/salt/top.sls || exit 4

# echo -e "\nStop firewall (todo)\n"
# sudo systemctl stop firewalld && systemctl disable firewalld

echo -e "\nInstalling everything using saltstack-formulas IaC\n"
echo -e "\n Please wait patiently ... or come back later ... this takes circa 15 mins\n"
sudo salt-call state.highstate --local
sudo systemctl stop salt-master && sudo systemctl disable salt-master  # not needed

echo -e "\nRefresh Dags ..."
cd ~/dags && rm -fr * && cp -Rp ../airflow-dags/dags/* .; chmod +x $( find . -name *.py)

## ensure ntp is okay ##
sudo timedatectl set-ntp on
sudo systemctl enable ntpd
sudo systemctl stop ntpd
sudo ntpd -gq
sudo systemctl start ntpd

echo -e "\ndone\n"
