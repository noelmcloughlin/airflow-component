# Lightweight federated Apache-Airflow Installer

Provision a federated implementation architecture (or single-node) deployment of Apache Airflow (RabbitMQ and Postgres), using a single-source-of-truth Configuration as Code interface.

![Airflow-Component](/templates/img/airflow-component.png?raw=true "Federated Airflow, Reference Deployment Architecture")

    primary:   controller01.main.net   user: main\airflowservice  - Active Scheduler, UI, worker
    secondary: controller02.main.net   user: main\airflowservice  - Standby Scheduler, UI, worker

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
    worker: worker01.fog.net           user: fog\airflowservice
    worker: worker02.fog.net           user: fog\airflowservice


# TL'DR

    ~/airflow-component/installer.sh | tee ~/iac-installer.log

# PREPARE

Declare your configuration in [https:/github.com/noelmcloughlin/airflow-component/blob/master/sitedata.j2](https://github.com/noelmcloughlin/airflow-component/blob/master/sitedata.j2)

Commission your infrastructure inline with [our infra ticket guidelines](https://github.com/noelmcloughlin/airflow-component/blob/master/INFRA.md)

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

Logon as airflowservice on participating hosts and users.

Get the software:

    cd && rm -fr airflow-component airflow-dags
    for name in component dags; do
        git clone https://github.com/noelmcloughlin/airflow-${name}
    done && cd ~/dags && rm -fr * && cp -Rp ../airflow-dags/dags/* .; chmod +x $( find . -name *.py)

Note, for hosts with no network connectivity to your git repo (i.e. fog), use another transfer method (i.e. sftp). Refer to [SUPPORT](https://github.com/noelmcloughlin/airflow-component/blob/master/SUPPORT.md)

On each participating host (begin with primary/secondary), install Airflow. The process takes ~15mins:

    ~/airflow-component/installer.sh | tee ~/iac-installer.log

Note, the installation summary may indicate failures. Evaluate result as follows:

    - Success if 0 task fails: cluster join worked too. OK!
    - Success if 1 task fails: cluster join is best effort, other node was not ready. OK!
    - Retryable if >1 task fails: sometimes the 2nd attempt just works! NOK!
    - Everything else needs troubleshooting. Refer to [SUPPORT](https://github.com/noelmcloughlin/airflow-component/blob/master/SUPPORT.md)


# POST INSTALL

On primary or secondary host, import airflow variables:

    airflow variables import ~/airflow-dags/variables.json


## AIRFLOW UI

- http://primary.controller.net:18080    (user/pass: airflow/airflow or custom)
- http://secondary.controller.net:18080  (user/pass: ditto)

### RabbitMQ UI

- http://primary.controller.net:15672    (user/pass: airflow/airflow)
- http://secondary.controller.net:15672  (user/pass: airflow/airflow)
- http://[worker-ipaddr]:15672           (user/pass: airflow/airflow)

### Celery Flower UI

- http://primary.controller.net:5555
- http://secondary.controller.net:5555
- http://[worker-ipaddr]:5555
