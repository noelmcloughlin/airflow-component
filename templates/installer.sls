base:
  '*':
    - sudoers
    - hostsfile

        {%- if salt['pillar.get']('airflow:identity:airflow:role', False) == 'localdb' %}
            # only needed if we are installing db on the controller
    - postgres.dropped
    - postgres
        {%- endif %}

        {%- if salt['pillar.get']('airflow:config:airflow:content:core:executor', False) == 'CeleryExecutor' %}

    - rabbitmq.clean  # skips /var/lib/rabbitmq
    - rabbitmq

        {%- endif %}

    - airflow
