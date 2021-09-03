# Airflow-Component TROUBLESHOOTING AND SUPPORT

See [README](https://github.com/noelmcloughlin/airflow-component/blob/master/README.md)

## SFTP transfer

For hosts without network connectivity to git you could use sftp:

    cd ~ && tar -cvf air.tar airflow-component airflow-dags
    sftp airflowservice@worker01.fog.net; sftp airflowservice@worker02.fog.net
    Connected to airflowservice@worker01.fog.net.
    sftp> put air.tar
    Uploading air.tar to /home/airflowservice/air.tar
    air.tar                                      100% 2590KB   5.0MB/s   00:00
    sftp> bye
    # then on worker01/02 extract the software:
    rm -fr ~/airflow-component ~/airflow-dags
    tar xvf ~/air.tar && rm tar.tar

## GENERAL

Ensure the proxy is applied in the environment (`env | grep -i proxy`).

Firewalld and Selinux is supported!

Ensure servers use NTP synchronization. If not then fix (i.e. sync/enable/start ntp):

    $ sudo -s
    $ systemctl stop ntpd
    $ ntpd -gq
    $ systemctl start ntpd && systemctl enable ntpd
    $ sleep 10 && timedatectl
        Local time: Tue 2021-08-10 18:01:15 UTC
    Universal time: Tue 2021-08-10 18:01:15 UTC
          RTC time: Tue 2021-08-10 18:01:15
         Time zone: UTC (UTC, +0000)
       NTP enabled: yes
       NTP synchronized: yes                #<===== here!!!

Check services:

    sudo -s
    systemctl status airflow-scheduler         # active primary, standby secondary
    systemctl status airflow-webserver         # active primary/secondary
    systemctl status airflow-celery-worker     # active
    systemctl status airflow-celery-flower     # active
    systemctl status rabbitmq-server           # active all servers

## DB ISSUES

During installation 'db init' fails with [airflow._vendor.connexion.exceptions.ResolverError: <ResolverError: columns>](https://stackoverflow.com/questions/67328545/error-while-initializing-database-in-apache-airflow-below-is-the-attached-error). Cause is unknown so retry install (change something).

## INSTALL ISSUES

### Log search

View install log using 'vi ~/iac-installer.log'.
To find failures type `/Result: False` to goto failed states.

### Unexpected installer outcomes (something funny going on)

Wipe the related directories and reinstall.

### ARCHLINUX

You need Salt python3 installed:

    pacman -Sy base-devel curl; curl -sSL https://aur.archlinux.org/cgit/aur.git/snapshot/salt-py3.tar.gz | tar xz; 

### CENTOS7

### Install stuck on same step for long time

Reboot and try again. Sometimes on CentOS7 an software upgrade pulls in a new kernel version needing reboot.

#### Permissions on CentOS7

No permissions for /var/log/piplogs directory:

    sudo chmod 777 /var/log/piplogs/pip

Afterwards reset back:

    sudo chmod 544 /var/log/piplogs/pip

#### Dependency hell resolutions:

[1] Wrong rpm package version:

    Error: Package: python36-rpm-4.11.3-9.el7.x86_64 (epel)
       Requires: rpm >= 4.11.3-45
       Installed: rpm-4.11.3-40.el7.x86_64 (@base)
           rpm = 4.11.3-40.el7
    You could try using --skip-broken to work around the problem
    You could try running: rpm -Va --nofiles --nodigest

Solution (try again afterwards):

    curl -LO https://mirror.netzwerge.de/centos/7/os/x86_64/Packages/rpm-4.11.3-45.el7.x86_64.rpm
    sudo rpm -Uvh rpm-4.11.3-45.el7.x86_64.rpm --nodeps

[2] Wrong krb5-libs package version:

    ---> Package krb5-devel.x86_64 0:1.15.1-37.el7_6 will be installed
    --> Processing Dependency: libkadm5(x86-64) = 1.15.1-37.el7_6 for package: krb5-devel-1.15.1-37.el7_6.x86_64
    --> Processing Dependency: krb5-libs(x86-64) = 1.15.1-37.el7_6 for package: krb5-devel-1.15.1-37.el7_6.x86_64
    --> Finished Dependency Resolution
    Error: Package: krb5-devel-1.15.1-37.el7_6.x86_64 (base)
           Requires: krb5-libs(x86-64) = 1.15.1-37.el7_6
           Installed: krb5-libs-1.15.1-50.el7.x86_64 (@base)

Solution (try again afterwards):

    yum install yum-utils -y
    yumdownloader libkadm5-1.15.1-37.el7_6.x86_64
    yumdownloader krb5-libs-1.15.1-37.el7_6.x86_64
    yumdownloader krb5-workstation-1.15.1-37.el7_7.2
    rpm -Uvh --oldpackage krb5-workstation-1.15.1-37.el7_7.2.x86_64.rpm  --nodeps
    rpm -Uvh --oldpackage libkadm5-1.15.1-37.el7_6.x86_64.rpm --nodeps
    rpm -Uvh --oldpackage krb5-libs-1.15.1-37.el7_6.x86_64.rpm --nodeps
    yum update -y
    yum install krb5-devel -y


## ANY OS

### rabbitmq-server will not start and it is unclear why

Reinstall and/or check clusering status and resolve inconsistent state.

### rabbitmq cluster formation is best effort

If other rabbit node is ready and able, join succeeds.

If other node is not ready, the join fails. This is expected and can be ignored on fresh installs:

    [ERROR   ] Command '/usr/sbin/rabbitmqctl' failed with return code: 69
    [ERROR   ] stdout: Clustering node rabbit@worker02 with rabbit@worker01

If rabbitmq cluster is inconsistent you must resolve this manually:

    rabbitmqctl stop_app
    rabbitmqctl forget_cluster_node rabbit@HOST_BEING_REINSTALLED
    rabbitmqctl start_app

    rabbitmqctl stop_app
    rabbitmqctl join_cluster rabbit@HOST_ALREAD_IN_CLUSTER
    rabbitmqctl start_app

### Debug Airflow UI Logins

Failed authentication in the Airflow UI authentication can be tricky when using an external services like LDAP or oAuth, configured in ~/airflow/webserver_config.py. Third party tools (i.e. Softerra ldap browser) can be used to review actual configuration needed.

You can manually troubleshoot Airflow UI failed authentications as follows:


    sudo systemctl stop airflow-webserver
    export AIRFLOW__LOGGING__FAB_LOGGING_LEVEL=DEBUG
    export PATH="/home/$( id -un)/.local/bin:$PATH:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin"

Start Airflow UI [repeatme]:

    /home/$(id -un)/.local/bin/airflow webserver >bob 2>&1

Test login in Airflow UI, and press CTRL+C in terminal to exit. View the logfile:

    vi bob

Fix issues (update webserver_config.py file), try again (start Airflow UI [repeatme]) until logins work, and cleanup:

    unset AIRFLOW__LOGGING__FAB_LOGGING_LEVEL
    sudo systemctl start airflow-webserver


# SUPPORT CHANNELS

For IaC Installer support raise issue at https://github.com/noelmcloughlin/airflow-component

## References

### IaC Installer
- https://github.com/saltstack-formulas/airflow-formula
- https://github.com/saltstack-formulas/salter

### Airflow
- https://www.cloudwalker.io/2019/09/09/airflow-using-rabbitmq-and-celery
- https://corecompete.com/scaling-out-airflow-with-celery-and-rabbitmq-to-orchestrate-etl-jobs-on-the-cloud
- https://victor.4devs.io/en/queue-servers/rabbitmq-federation-plugin.html
- https://www.rabbitmq.com/federation-reference.html
- https://www.cloudamqp.com/blog/rabbitmq-quorum-queues.html
- https://www.cloudamqp.com/blog/part4-rabbitmq-for-beginners-exchanges-routing-keys-bindings.html
- https://www.compose.com/articles/configuring-rabbitmq-exchanges-queues-and-bindings-part-2
- https://learnk8s.io/scaling-celery-rabbitmq-kubernetes
- https://azure.microsoft.com/es-es/blog/deploying-apache-airflow-in-azure-to-build-and-run-data-pipelines
- https://medium.com/apache-airflow/airflow-2-0-dag-authoring-redesigned-651edc397178
