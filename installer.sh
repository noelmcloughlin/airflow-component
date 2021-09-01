#!/usr/bin/env bash
trap exit SIGINT SIGTERM
clear

# For various reasons run installer.sh as nonroot and switch to sudo as needed
[ "$(id -u)" == 0 ] && echo -e "\nSwitch to nonroot airflow user, exiting\n" && exit 1

IAC_CFG_DIR=/srv/pillar/saltstack-formulas
IAC_RUN_DIR=/srv/salt/namespaces/saltstack-formulas
components="airflow rabbitmq postgres redis hostsfile sudoers"

# garbage collection (can salter do this?)
for comp in ${components}; do
    sudo rm -fr ${IAC_RUN_DIR}/${comp}-formula/airflow 2>/dev/null  # salter should do this!!
done
CENTOS7_TECH_DEBT=$( rpm -E %{rhel} 2>/dev/null )
(( $? == 0 )) && (( CENTOS7_TECH_DEBT == 7 )) && export SALT_VERSION='stable 3001'

# Salter (https://github.com/saltstack-formulas/salter)
curl -LO https://raw.githubusercontent.com/saltstack-formulas/salter/master/go.sh && bash go.sh
if (( $? > 0 ));then
    echo -e "\nReport the issue: https://github.com/noelmcloughlin/airflow-component/issues"
    exit 11
fi

# garbage collection (can salter do this? salter#84)
for comp in ${components}; do
    sudo ln -s  ${IAC_RUN_DIR}/${comp}-formula /srv/salt/${comp} 2>/dev/null
done

# Salter populates ${IAC_CFG_DIR} with defaults, remove them
[[ "${IAC_CFG_DIR}x" == "/x" ]] && echo -e "\nwarning: variable IAC_CFG_DIR evaluates to /" && exit 12
sudo rm -fr ${IAC_CFG_DIR}/* /srv/salt/top.sls 2>/dev/null  # recursive delete
sudo rm ~/go.sh ~/salter.sh ~/air.tar 2>/dev/null

# garbage collection
echo -e "\nWorkaround Airflow version < 2.2 does not support different dag_home paths\n"
sudo ln -s /home/$(id -un) /home/_airflowservice@GBECORP.GBE.global 2>/dev/null

echo -e "\nPreparing Configuration as Code\n"
CFG_DIR=~/airflow-component
sudo cp ${CFG_DIR}/sitedata.*          ${IAC_CFG_DIR}/ || exit 2
sudo cp ${CFG_DIR}/templates/federate* ${IAC_CFG_DIR}/ || exit 2
sudo cp ${CFG_DIR}/templates/installer.sls /srv/salt/top.sls || exit 4

echo -e "\n Installing Airflow ... please wait patiently or come back in ~15 mins\n"
sudo salt-call state.highstate --local
sudo systemctl stop salt-master && sudo systemctl disable salt-master  # service not needed

# sync dags
if [[ -d ~/dags ]] && [[ -d ~/airflow-dags ]]; then
    echo -e "\nRefresh Dags ..."
    cd ~/dags && rm -fr * && cp -Rp ../airflow-dags/dags/* .
    (( $? == 0 )) && chmod +x $( find . -name *.py)
fi

# sync ntp
if [[ -x /usr/sbin/ntpd ]]; then
    ## ensure ntp is okay ##
    sudo timedatectl set-ntp on
    sudo systemctl enable ntpd
    sudo systemctl stop ntpd
    sudo ntpd -gq
    sudo systemctl start ntpd
fi
echo -e "\ndone\n"
