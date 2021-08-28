# FEDERATED APACHE AIRFLOW INFRA PLAN
https://github.com/noelmcloughlin/airflow-component

To assist sprint planning, this document is an exhaustive list of "ticket slogans" which to be refined as tasks for your infra team to be consumed by [airflow-component installer](https://github.com/noelmcloughlin/airflow-component#readme) or another installer, based on [Official airflow docs](https://airflow.apache.org/docs/apache-airflow/stable/installation.html):

![Airflow-Component](/templates/img/airflow-component.png?raw=true "Federated Airflow, Reference Deployment Architecture")

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

Request compute for apache-airflow controllers and workers. OS must be GNU/Linux (RedHat, Ubuntu):

1. [controller] Commission two [controllertype] compute hosts

2. [applesdev] Commision two [workertype] compute hosts

3. [orangesdev] Commision two [workertype] compute hosts

4. [applestest] Commision two [workertype] compute hosts

5. [orangestest] Commision two [workertype] compute hosts

6. [apples] Commision two [workertype] compute hosts

7. [oranges] Commision two [workertype] compute hosts

8. [edge] Commision two [workertype] compute hosts

9. [fog] Commision two [workertype] compute hosts

## WebProxy

Request these entries be added to proxy for airflow-component Installer:

    *.apache.org:443
    *.bootstrap.pypa.io:443
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
    *.mirrors.up.pt:443
    *.mirrors.nxthost.com:443
    *.fedora.cu.be:443
    *.epel.mirror.omnilance.com:443
    *.mirror.netzwerge.de:443

1. [controller] update proxy with [installer] mirrors

2. [applesdev] update proxy with [installer] mirrors

3. [orangesdev] update proxy with [installer] mirrors

4. [applestest] update proxy with [installer] mirrors

5. [orangestest] update proxy with [installer] mirrors

6. [apples] update proxy with [installer] mirrors

7. [oranges] update proxy with [installer] mirrors

8. [edge] update proxy with [installer] mirrors

9. [fog] update proxy with [installer] mirrors


## Airflow Database

Request access to airflow database from workers.

1. [applesdev] open access to remote postgres port 5432

2. [orangesdev] open access to remote postgres port 5432

3. [applestest] open access to remote postgres port 5432

4. [orangestest] open access to remote postgres port 5432

5. [apples] open access to remote postgres port 5432

6. [oranges] open access to remote postgres port 5432

7. [edge] open access to remote postgres port 5432

8. [fog] open access to remote postgres port 5432

## airflow worker logs

Request access to worker task log files from controllers:

1. [applesdev] allow controllers to access worker port 8793 [airflow]

2. [orangesdev] allow controllers to access worker port 8793 [airflow]

3. [applestest] allow controllers to access worker port 8793 [airflow]

4. [orangestest] allow controllers to access worker port 8793 [airflow]

5. [apples] allow controllers to access worker port 8793 [airflow]

6. [oranges] allow controllers to access worker port 8793 [airflow]

7. [edge] allow controllers to access worker port 8793 [airflow]

8. [fog] allow controllers to access worker port 8793 [airflow]

## RabbitMQ port

Workers must be able to communicated with RabbitMQ on the controller domain per this ticket.

1. [applesdev] open access to [federated rabbitmq] port 5672

2. [orangesdev] open access to [federated rabbitmq] port 5672

3. [applestest] open access to [federated rabbitmq] port 5672

4. [orangestest] open access to [federated rabbitmq] port 5672

5. [apples] open access to [federated rabbitmq] port 5672

6. [oranges] open access to [federated rabbitmq] port 5672

7. [edge] open access to [federated rabbitmq] port 5672

8. [fog] open access to [federated rabbitmq] port 5672


## RabbitMQ Clustering ports

This ticket allows PAIRS (controller01/02, worker01/02) to form cluster pairs (a<->b) over standard ports. We will create multiple independent rabbitmq two-node clusters for contoller, applesdev, applestest, apples, orangesdev, orangestest, oranges, edge, fog domains:

1. [controller] allow controller01/02 to form cluster on ports 25672,4369

2. [applesdev] allow worker01/02 to form cluster on ports 25672,4369

3. [orangesdev] allow worker01/02 to form cluster on ports 25672,4369

4. [applestest] allow worker01/02 to form cluster on ports 25672,4369

5. [orangestest] allow worker01/02 to form cluster on ports 25672,4369

6. [apples] allow worker01/02 to form cluster on ports 25672,4369

7. [oranges] allow worker01/02 to form cluster on ports 25672,4369

8. [edge] allow worker01/02 to form cluster on ports 25672,4369

9. [fog] allow worker01/02 to form cluster on ports 25672,4369


## git repo acccess (optional)

Allow synchronization of our git repo to controllers and workers (fog workers have no network connectivity).

1. [controller] allow git clone access to our repo

2. [applesdev] allow git clone access to our repo

3. [orangesdev] allow git clone access to our repo

4. [applestest] allow git clone access to our repo

5. [orangestest] allow git clone access to our repo

6. [apples] allow git clone access to our repo

7. [oranges] allow git clone access to our repo

8. [edge] allow git clone access to our repo

## Airflow Service Accounts (optional)

The installer works with POSIX Linux users. Maybe you need something else (i.e. "Service Accounts" for cloud resources):

1. [controller] create [airflow] airflowservice account

2. [applesdev] create [airflow] airflowservice account

3. [applestest] create [airflow] airflowservice account

4. [apples] create [airflow] airflowservice account

5. [orangesdev] create [airflow] airflowservice account

6. [orangestest] create [airflow] airflowservice account

7. [oranges] create [airflow] airflowservice account

8. [edge] create [airflow] airflowservice account

# References

- https://airflow.apache.org/docs/apache-airflow/stable/installation.html
- https://www.rabbitmq.com/clustering.html
