# AIRFLOW INFRA PLANNING

To assist sprint planning, this document is an exhaustive list of "ticket slogans" which to be refined as tasks for your infra team to be consumed by [airflow-component installer](https://github.com/noelmcloughlin/airflow-component#readme) or another installer, based on [Official airflow docs](https://airflow.apache.org/docs/apache-airflow/stable/installation.html):

![Airflow-Component](/img/airflow-component.png?raw=true "Federated Airflow, Reference Deployment Architecture")

    primary:   controller01.controller.net  user: controller\airflowservice  - Active Scheduler, UI, worker
    secondary: controller02.controller.net  user: controller\airflowservice  - Standby Scheduler, UI, worker

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

# TICKET SLOGANS

## Server requests

This ticket is required to host apache-airflow controllers and workers federated architecture. OS must be Linux.

1. [controller][controllertype] Commission two compute hosts

2. [applesdev][workertype] Commission two compute hosts

3. [orangesdev][workertype] Commission two compute hosts

4. [applestest][workertype] Commission two compute hosts

5. [orangestest][workertype] Commission two compute hosts

6. [apples][workertype] Commission two compute hosts

7. [oranges][workertype] Commission two compute hosts

8. [edge][workertype] Commission two compute hosts

9. [fog][workertype] Commission two compute hosts

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
    *.linux.duke.edu :443
    *.cloudfront.net:443

    *.ftp.fi.muni.cz:443
    *. mirrors.up.pt:443
    *. mirrors.nxthost.com:443
    *. fedora.cu.be:443
    *. epel.mirror.omnilance.com:443
    *. mirror.netzwerge.de:443

This ticket requests internet access for "Salter" IaC Installer, to install Airflow stack (postgres, rabbitmq, airflow)

1. [controller][iac] update proxy with these wildcard hosts

2. [applesdev][iac] update proxy with these wildcard hosts

3. [orangesdev][iac] update proxy with these wildcard hosts

4. [applestest][iac] update proxy with these wildcard hosts

5. [orangestest][iac] update proxy with these wildcard hosts

6. [apples][iac] update proxy with these wildcard hosts

7. [oranges][iac] update proxy with these wildcard hosts

8. [edge][iac] update proxy with these wildcard hosts

9. [fog][iac] update proxy with these wildcard hosts


## Airflow Database

This ticket gives the workers access airflow database:

1. [applesdev][airflow] open access to postgres port 5432

2. [orangesdev][airflow] open access to postgres port 5432

3. [applestest][airflow] open access to postgres port 5432

4. [orangestest][airflow] open access to postgres port 5432

5. [apples][airflow] open access to postgres port 5432

6. [oranges][airflow] open access to postgres port 5432

7. [edge][airflow] open access to postgres port 5432

8. [fog][airflow] open access to postgres port 5432
    
## airflow worker logs

This ticket allows Airflow UI to retrieve and display worker task log files centrally:

1. [applesdev][airflow] allow controllers to http get port 8793

2. [orangesdev][airflow] allow controllers to http get port 8793

3. [applestest][airflow] allow controllers to http get port 8793

4. [orangestest][airflow] allow controllers to http get port 8793

5. [apples][airflow] allow controllers to http get port 8793

6. [oranges][airflow] allow controllers to http get port 8793

7. [edge][airflow] allow controllers to http get port 8793

8. [fog][airflow] allow controllers to http get port 8793
    
## git repo acccess (optional)

This ticket allows Airflow hosts to retrieve software from git repository which has network connectivity (not fog.net), but needs explicit access:

1. [controller][iac] allow git clone access to our repo

2. [applesdev][iac] allow git clone access to our repo

3. [orangesdev][iac] allow git clone access to our repo

4. [applestest][iac] allow git clone access to our repo

5. [orangestest][iac] allow git clone access to our repo

6. [apples][iac] allow git clone access to our repo

7. [oranges][iac] allow git clone access to our repo

8. [edge][iac]  allow git clone access to our repo

## Airflow Service Accounts

The installer works with native POSIX Linux users. This ticket requests a "Service Account" if cloud access is needed:

1. [controller][airflow] create airflowservice account

2. [applesdev][airflow] create airflowservice account

3. [applestest][airflow] create airflowservice account

4. [apples][airflow] create airflowservice account

5. [orangesdev][airflow] create airflowservice account

6. [orangestest][airflow] create airflowservice account

7. [oranges][airflow] create airflowservice account

8. [edge][airflow] create airflowservice account

## RabbitMQ port

Workers must be able to communicated with RabbitMQ on the controller domain per this ticket.

1. [applesdev][airflow] open access to federated rabbitmq port 5672

2. [orangesdev][airflow] open access to federated rabbitmq port 5672

3. [applestest][airflow] open access to federated rabbitmq port 5672

4. [orangestest][airflow] open access to federated rabbitmq port 5672

5. [apples][airflow] open access to federated rabbitmq port 5672

6. [oranges][airflow] open access to federated rabbitmq port 5672

7. [edge][airflow] open access to federated rabbitmq port 5672

8. [fog][airflow] open access to federated rabbitmq port 5672
    

## RabbitMQ Clustering ports

This ticket allows PAIRS (controller01/02, worker01/02) to form cluster pairs (a<->b) over standard ports. We will create multiple independent rabbitmq two-node clusters for contoller, applesdev, applestest, apples, orangesdev, orangestest, oranges, edge, fog domains:

1. [controller][airflow] allow controller pairs (01/02) to cluster on ports 25672,4369

2. [applesdev][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

3. [orangesdev][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

4. [applestest][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

5. [orangestest][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

6. [apples][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

7. [oranges][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

8. [edge][airflow] allow worker pairs (01/02) to cluster on ports 25672,4369

9. [fog][airflow] allow worker pairs to cluster on ports 25672,4369


# References

- https://airflow.apache.org/docs/apache-airflow/stable/installation.html
- https://www.rabbitmq.com/clustering.html
