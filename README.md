# Lightweight federated Apache-Airflow Installer

Provision federated (or single-node) reference deployment architecture of Apache Airflow (RabbitMQ, Postgres), via lightweight single-source-of-truth installer. Heavy lifting/CI by [Saltstack-formulas community](https://github.com/saltstack-formulas).
![Airflow-Component](/templates/img/airflow-component.png?raw=true "Federated Airflow, Reference Deployment Architecture")

    primary:   controller01.main.net  user: main\airflowservice  - Active Scheduler, UI, worker
    secondary: controller02.main.net  user: main\airflowservice  - Standby Scheduler, UI, worker
    worker01/02: apples, applesdev, applestest
    worker01/02: oranges, orangesdev, orangestest
    worker01/02: edge
    worker01/02: fog

# TL'DR

    ~/airflow-component/installer.sh | tee ~/iac-installer.log

# PREPARE

Declare your configuration in [sitedata.j2](https://github.com/noelmcloughlin/airflow-component/blob/master/sitedata.j2)

Commission your infrastructure inline with [our infra ticket guidelines](https://github.com/noelmcloughlin/airflow-component/blob/master/INFRA.md)

Logon as airflowservice on each participating host and user.

Ensure proxy is published ~/.bashrc and ~/airflow-component/installer.sh files if applicable:

    export HTTP_PROXY="http://myproxy:8080"
    export HTTPS_PROXY="http://myproxy:8080"
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTPS_PROXY}"
    export no_proxy="localhost,*.net"
    export PATH=${PATH}:/usr/local/bin

Plan to deploy primary/secondary hosts before workers.

Optionally wipe data on any-all servers before reinstall. Normally this is not needed!!

    sudo rm -fr ~/.local /var/lib/rabbitmq/ /var/log/rabbitmq/ /usr/lib/systemd/system/rabbitmq-serv* /usr/lib/systemd/system/airflow-* /etc/rabbitmq/ /var/lib/pgsql /srv/salt && sudo reboot


# (RE)INSTALL/UPGRADE

Logon as airflowservice on participating hosts and users. Get the software: For hosts without network connectivity to your git (i.e. from fog), use another method, i.e. sftp, see [SUPPORT](https://github.com/noelmcloughlin/airflow-component/blob/master/SUPPORT.md)

    cd && rm -fr airflow-component airflow-dags
    for name in component dags; do
        git clone https://github.com/noelmcloughlin/airflow-${name}
    done && cd ~/dags && rm -fr * && cp -Rp ../airflow-dags/dags/* .; chmod +x $( find . -name *.py)

On each participating host (begin with primary/secondary), install Airflow. Duration is ~15-30mins depending on compute resources:

    ~/airflow-component/installer.sh | tee ~/iac-installer.log

Note, the installation summary may indicate failures. Evaluate result as follows. For failures see [SUPPORT](https://github.com/noelmcloughlin/airflow-component/blob/master/SUPPORT.md)

    - Success if 0 task fails: cluster join worked too. OK!
    - Success if 1 task fails: cluster join is best effort, other node was not ready (race condition). OK!
    - Retryable if >1 task fails: sometimes the 2nd attempt just works! NOK!
    - All other outcomes are failures.

Import variables:

    airflow variables import ~/airflow-dags/variables.json

# USER INTERFACE

Airflow:
- http://primary.main.net:18080    (user/pass: airflow/airflow or custom)
- http://secondary.main.net:18080  (user/pass: ditto)

RabbitMQ:
- http://primary.main.net:15672    (user/pass: airflow/airflow)
- http://secondary.main.net:15672  (user/pass: airflow/airflow)
- http://[worker-ipaddr]:15672           (user/pass: airflow/airflow)

Celery Flower:
- http://primary.main.net:5555
- http://secondary.main.net:5555
- http://[worker-ipaddr]:5555

# TROUBLESHOOTING

See [SUPPORT](https://github.com/noelmcloughlin/airflow-component/blob/master/SUPPORT.md)

