# Lightweight federated Apache-Airflow Installer

This airflow-component solution is designed to provision a federated implementation architecture for apache airflow, using Configuration as Code, or a single-host deployment if you prefer.

![Airflow-Component](/templates/img/airflow-component.png?raw=true "Federated Airflow, Reference Deployment Architecture")

    primary:   controller01.controller.net   user: controller\airflowservice  - Active Scheduler, UI, worker
    secondary: controller02.controller.net   user: controller\airflowservice  - Standby Scheduler, UI, worker

    worker: worker01.apples.net        user: apples\airflowservice
    worker: worker02.apples.net        user: apples\airflowservice
    worker: worker01.applestest.net    user: applestest\airflowservice
    worker: worker02.applestest.net    user: applestest\airflowservice
    worker: worker01.applesdev.net     user: applesdev\airflowservice
    worker: worker02.applesdev.net     user: applesdev\airflowservice

    worker: worker01.oranges.net       user: oranges\airflowservice
    worker: worker02.oranges.net       user: oranges\airflowservice
    worker: worker01.orangestest.net   user: orangestest\airflowservice
    worker: worker02.orangestest.net   user: orangestest\airflowservice
    worker: worker01.orangesdev.net    user: orangesdev\airflowservice
    worker: worker02.orangesdev.net    user: orangesdev\airflowservice

    worker: worker01.edge.net          user: edge\airflowservice
    worker: worker02.edge.net          user: edge\airflowservice
    worker: worker01.fog.net           user: airflowservice
    worker: worker02.fog.net           user: airflowservice


# TL'DR

    ~/airflow-component/installer.sh | tee ~/iac-installer.log

# PREPARE

Declare your configuration in [https:/github.com/noelmcloughlin/airflow-component/blob/master/sitedata.j2](https://github.com/noelmcloughlin/airflow-component/blob/master/sitedata.j2)

Commission your infrastructure inline with [our reference ticketing architecture](https://github.com/noelmcloughlin/airflow-component/blob/master/INFRA.md) guide.

Logon as airflowservice on each participating host and user, and ensure proxy is published (in ~/.bashrc).

    export HTTP_PROXY="http://myproxy:8080"
    export HTTPS_PROXY="http://myproxy:8080"
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    export no_proxy="localhost,*.net"
    export PATH=${PATH}:/usr/local/bin

Plan to deploy primary/secondary hosts before workers.

Optionally wipe data on any-all servers before reinstall. If unsure, skip this command:

    sudo rm -fr ~/.local /var/lib/rabbitmq/ /var/log/rabbitmq/ /usr/lib/systemd/system/rabbitmq-serv* /usr/lib/systemd/system/airflow-* /etc/rabbitmq/ /var/lib/pgsql /srv/salt && sudo reboot


# (RE)INSTALL/UPGRADE

Logon as airflowservice on participating hosts and users. Get the software:

    cd && rm -fr airflow-component airflow-dags
    for name in component dags; do
        git clone https://github.com/noelmcloughlin/airflow-${name}
    done && cd ~/dags && rm -fr * && cp -Rp ../airflow-dags/dags/* .; chmod +x $( find . -name *.py)

Note, for hosts with no network connectivity to your git repo (i.e. fog), use some other transfer method (i.e. sftp):

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

On each participating host (begin with primary/secondary), install Airflow. The process takes ~15mins:

    ~/airflow-component/installer.sh | tee ~/iac-installer.log

Note, the installation summary may indicate failures. Evaluate result as follows:

    - Success if 0 task fails: cluster join worked too. OK!
    - Success if 1 task fails: cluster join is best effort, other node was not ready. OK!
    - Retryable if >1 task fails: sometimes the 2nd attempt just works! NOK!
    - Failure if retry is not success. Review [TROUBLESHOOTING](#TROUBLESHOOTING) section below.


# POST INSTALL

On primary or secondary host, import your airflow variables:

    airflow variables import ~/airflow-dags/variables.json


## AIRFLOW UI

- http://primary.controller.net:18080    (user/pass: depends_on_auth_method_used)
- http://secondary.controller.net:18080  (user/pass: ditto)

### RabbitMQ UI

- http://primary.controller.net:15672    (user/pass: airflow/<redacted>)
- http://secondary.controller.net:15672  (user/pass: airflow/<redacted>)
- http://[worker-ipaddr]:15672           (user/pass: airflow/<redacted>)

### Celery Flower UI

- http://primary.controller.net:5555
- http://secondary.controller.net:5555
- http://[worker-ipaddr]:5555           (user/pass: airflow/<redacted>)


# TROUBLESHOOTING

## GENERAL

Ensure the proxy is applied in the environment (`env | grep -i proxy`).

Ensure firewalld is configured (`systemctl status/disable/stop firewalld`).

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


## INSTALL ISSUES

### Log search

View log file using 'vi'. Type `/Result: False` to goto failures in the ~/iac-installer.log file.


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

Fix issues (updating webserver_config.py file) and try again (start Airflow UI [repeatme]) until logins work. Then cleanup:

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
