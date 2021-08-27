# PROJECT PLAN: FEDERATED SCALABLE APACHE AIRFLOW

This is a guide for DevOps, SRE, and Data Engineer planning a scalable federated Apache-Airflow implemenation project.

Here is the Reference Deployment Architecture used to illustrate what tickets need to be raised for infra.

    host: primary.controller.net     user: controller\airflowservice  - Active Scheduler, UI, worker
    host: secondary.controller.net   user: controller\airflowservice  - Standby Scheduler, UI, worker

    host: worker01.applesdev.net     user: applesdev\airflowservice
    host: worker02.applesdev.net     user: applesdev\airflowservice
    host: worker01.applestest.net    user: applestest\airflowservice
    host: worker02.applestest.net    user: applestest\airflowservice
    host: worker01.apples.net        user: apples\airflowservice
    host: worker02.apples.net        user: apples\airflowservice

    host: worker01.orangesdev.net    user: orangesdev\airflowservice
    host: worker02.orangesdev.net    user: orangesdev\airflowservice
    host: worker01.orangestest.net   user: orangestest\airflowservice
    host: worker02.orangestest.net   user: orangestest\airflowservice
    host: worker01.oranges.net       user: oranges\airflowservice
    host: worker02.oranges.net       user: oranges\airflowservice

    host: worker01.edge.net          user: edge\airflowservice
    host: worker02.edge.net          user: edge\airflowservice
    host: worker01.fog.net           user: airflowservice
    host: worker02.fog.net           user: airflowservice

# TICKET SLOGANS

## Server requests

This ticket is required to host apache-airflow controllers and workers federated architecture. OS must be Linux.

1. [prod][controllertype] Commission two compute hosts

2. [dev][apples][workertype] Commission two compute hosts

3. [dev][oranges][workertype] Commission two compute hosts

4. [test][apples][workertype] Commission two compute hosts

5. [test][oranges][workertype] Commission two compute hosts

6. [prod][apples][workertype] Commission two compute hosts

7. [prod][oranges][workertype] Commission two compute hosts

8. [prod][edge][workertype] Commission two compute hosts

9. [prod][fog][workertype] Commission two compute hosts

## WebProxy 

We will install apache-airflow on all servers using "Salter" Infra as Code (IaC) installer and these endpoints:

    *.apache.org:443 
    *.bootstrap.pypa.io:44 
    *.postgresql.org:443 
    *.saltstack.com:443 
    *.fedoraproject.org:443 
    *.github.com:443 
    *.githubusercontent.com:443
    *.fedora.is:443
    *.cloudsmith.io:443
    *.packagecloud.io
    *.saltproject.io:443
    *.Linux @ Duke :443
    *.cloudfront.net:443

    *.ftp.fi.muni.cz:443
    *. mirrors.up.pt:443
    *. mirrors.nxthost.com:443
    *. fedora.cu.be:443
    *. epel.mirror.omnilance.com:443
    *. mirror.netzwerge.de:443

This ticket requests internet access for "Salter" IaC Installer, to install Airflow stack (postgres, rabbitmq, airflow)

1. [prod][controller][iac] update proxy with these wildcard hosts

2. [dev][apples][iac] update proxy with these wildcard hosts

3. [dev][oranges][iac] update proxy with these wildcard hosts

4. [test][apples][iac] update proxy with these wildcard hosts

5. [test][oranges][iac] update proxy with these wildcard hosts

6. [prod][apples][iac] update proxy with these wildcard hosts

7. [prod][oranges][iac] update proxy with these wildcard hosts

8. [prod][edge][iac] update proxy with these wildcard hosts

9. [prod][fog][iac] update proxy with these wildcard hosts


## Airflow Database

This ticket gives the workers access airflow database:

1. [dev][apples][airflow] open access to postgres port 5432

2. [dev][oranges][airflow] open access to postgres port 5432

3. [test][apples][airflow] open access to postgres port 5432

4. [test][oranges][airflow] open access to postgres port 5432

5. [prod][apples][airflow] open access to postgres port 5432

6. [prod][oranges][airflow] open access to postgres port 5432

7. [prod][edge][airflow] open access to postgres port 5432

8. [prod][fog][airflow] open access to postgres port 5432
    
## airflow worker logs

This ticket allows Airflow UI to retrieve and display worker task log files centrally:

1. [dev][apples][airflow] allow controllers to http get port 8793

2. [dev][oranges][airflow] allow controllers to http get port 8793

3. [test][apples][airflow] allow controllers to http get port 8793

4. [test][oranges][airflow] allow controllers to http get port 8793

5. [prod][apples][airflow] allow controllers to http get port 8793

6. [prod][oranges][airflow] allow controllers to http get port 8793

7. [prod][edge][airflow] allow controllers to http get port 8793

8. [prod][fog][airflow] allow controllers to http get port 8793
    
## git repo acccess (optional)

This ticket allows Airflow hosts to retrieve software from git repository which has network connectivity (not fog.net), but needs explicit access:

1. [dev][controller][iac] allow git clone access to our repo

2. [dev][apples][iac] allow git clone access to our repo

3. [dev][oranges][iac] allow git clone access to our repo

4. [test][apples][iac] allow git clone access to our repo

5. [test][oranges][iac] allow git clone access to our repo

6. [prod][apples][iac] allow git clone access to our repo

7. [prod][oranges][iac] allow git clone access to our repo

8. [prod][edge][iac]  allow git clone access to our repo

## Airflow Service Accounts

The installer works with native POSIX Linux users. This ticket requests a "Service Account" if cloud access is needed:

1. [dev][controller][airflow] create airflowservice account

2. [dev][apples][airflow] create airflowservice account

3. [test][apples][airflow] create airflowservice account

4. [prod][apples][airflow] create airflowservice account

5. [dev][oranges][airflow] create airflowservice account

6. [test][oranges][airflow] create airflowservice account

7. [prod][oranges][airflow] create airflowservice account

8. [prod][edge][airflow] create airflowservice account

## RabbitMQ port

Workers must be able to communicated with RabbitMQ on the controller domain per this ticket.

1. [dev][apples][airflow] open access to federated rabbitmq port 5672

2. [dev][oranges][airflow] open access to federated rabbitmq port 5672

3. [test][apples][airflow] open access to federated rabbitmq port 5672

4. [test][oranges][airflow] open access to federated rabbitmq port 5672

5. [prod][apples][airflow] open access to federated rabbitmq port 5672

6. [prod][oranges][airflow] open access to federated rabbitmq port 5672

7. [prod][edge][airflow] open access to federated rabbitmq port 5672

8. [prod][fog][airflow] open access to federated rabbitmq port 5672
    

## RabbitMQ Clustering ports

This ticket allows PAIRS (controller01/02, worker01/02) to form cluster pairs (a<->b) over standard ports. We will create multiple independent rabbitmq two-node clusters for contoller, applesdev, applestest, apples, orangesdev, orangestest, oranges, edge, fog domains:
1. [dev][apples][airflow] allow controller pairs (01/02) to cluster on ports 25672,4369

2. [dev][apples][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

3. [dev][oranges][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

4. [test][apples][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

5. [test][oranges][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

6. [prod][apples][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

7. [prod][oranges][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

8. [prod][edge][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

9. [prod][fog][airflow] allow worker pairs to cluster on ports 25672,4369


# References

- https://airflow.apache.org/docs/apache-airflow/stable/installation.html
- https://www.rabbitmq.com/clustering.html
