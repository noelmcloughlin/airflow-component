# -*- coding: utf-8 -*-
# vim: ft=yaml
---
{%- set tplroot = tpldir.split('/')[0] %}
{%- import tplroot ~ "/sitedata.j2" as my %}
{%- set domain = my['domain'] %}

# https://github.com/saltstack-formulas/hostsfile-formula/blob/master/pillar.example
hostsfile:
  only:
        {%- for domainname in my.domains %}
            {%- if 'workers' in my[domainname] %}
                {%- for k,v in my[domainname]['workers'].items() %}
                    {%- if v not in ('127.0.0.1', '::1') %}
    {{ v }}:
      - {{ k }}
                    {%- endif %}
                {%- endfor %}
            {%- endif %}
        {%- endfor %}

# https://github.com/saltstack-formulas/sudoers-formula/blob/master/pillar.example
sudoers:
  manage_main_config: false
  included_files:
    /etc/sudoers.d/airflow-impersonation:
      groups:
        {{ my[domain]['group']|string }}:
          - 'ALL=(ALL) NOPASSWD: ALL'
      # users:
      #   {{ my[domain]['user']|string }}:
      #     - 'ALL=(ALL) NOPASSWD: ALL'
  append_included_files_to_endof_main_config: true  # bottom of /etc/sudoers

# https://github.com/saltstack-formulas/airflow-formula/blob/master/pillar.example
airflow:
  linux:
    selinux: {{ my.selinux }}
    firewall: {{ my.firewall }}
  identity:
    airflow:
      user: {{ my[domain]['user']|string }}
      group: {{ my[domain]['group']|string }}
      create_user_group: {{ my['create_user_group']|string }}
        {%- if grains.host == my.primaryhost|string %}
      role: localdb    # only for local testing
        {%- endif %}
  database:
    airflow:
      user: airflow
      pass: airflow
      email: airflow@localhost
  config:
    airflow:
      content:
        api: {}
        celery_kubernetes_executor: {}
        celery:
          # https://docs.celeryproject.org/en/v5.0.2/getting-started/brokers
          broker_url: amqp://airflow:airflow@127.0.0.1:5672/airflow   # always 127.0.0.1
          result_backend: db+postgresql://{{ my[domain]['database']|string }}
        cli: {}
        core:
          dags_folder: /home/{{ my[domain]['user']|string }}/dags
          default_impersonation: {{ my[domain]['user']|string }}
          plugins_folder: /home/{{ my[domain]['user']|string }}/plugins
          executor: CeleryExecutor
          default_timezone: utc
          load_examples: false
          # https://stackoverflow.com/questions/45455342
          # once DBA's take over PostgresDB, changeme
          sql_alchemy_conn: postgresql+psycopg2://{{ my[domain]['database']|string }}
          security: ''
        webserver:
          secret_key: {{ my.webserversecret }}
        operators:
          default_queue: {{ domain }}
          {%- if grains.osfinger == 'CentOS Linux-7' %}
      venv_cmd: virtualenv-3
          {%- endif %}
      pip_cmd: pip3
      flask:
        # https://flask-appbuilder.readthedocs.io/en/latest/security.html#authentication-ldap
        auth_type: {{ 'AUTH_DB' if 'auth_type' not in my[domain] else my[domain]['auth_type'] }}
        auth_ldap_server: ldap://{{ my[domain]['ldapserver']|string }}  # include protocol (ldap or ldaps)
        auth_ldap_append_domain: {{ my[domain]['fqdn']|string }}
        auth_ldap_uid_field: 'sAMAccountName'  # or 'userPrincipalName'
        auth_ldap_search: "{{ my[domain]['ldapbase']|string }}"
        ## see https://confluence.atlassian.com/kb/how-to-write-ldap-search-filters-792496933.html
        auth_ldap_search_filter: {{ my[domain]['ldapfilter']|string }}
        auth_user_registration_role: User # role, in addition to any AUTH_ROLES_MAPPING
        auth_user_registration: true   # allow users who are not already in the FAB DB
        auth_roles_mapping:
          CN=grpRole_AppSupport,{{ my[domain]['ldapbase']|string }}: Admin
          CN=grpRole_Infrastructure,{{ my[domain]['ldapbase']|string }}: Admin
        webserver:
          web_server_host: 0.0.0.0
          web_server_port: 18080

      state_colors:
        # https://airflow.apache.org/docs/apache-airflow/stable/howto/customize-state-colors-ui.html
        queued: 'darkgray'
        running: '#01FF70'
        success: '#2ECC40'
        failed: 'firebrick'
        up_for_retry: 'yellow'
        up_for_reschedule: 'turquoise'
        upstream_failed: 'orange'
        skipped: 'darkorchid'
        scheduled: 'tan'
  service:
    airflow:
      worker_run_as_sudo: true
      enabled:
        - airflow-celery-flower
        - airflow-celery-worker
              {%- if grains.host == my.primaryhost|string %}
        - airflow-scheduler
              {%- endif %}
              {%- if my[domain]['name'] == my.primarydomain|string %}
        - airflow-webserver
              {%- endif %}
      queues:   # to listen to
        - {{ my[domain]['name']|string }}
        - {{ grains.host }}
  pkg:
    airflow:
      ################################
      #    VERSION OF AIRFLOW        #
      ################################
      version: {{ my['airflow_version']|string }}
              {%- if grains.osfinger == 'CentOS Linux-7' %}
          # because centos7 defaults to python2, need to be explicit
      uri_c: https://raw.githubusercontent.com/apache/airflow/constraints-VERSION/constraints-3.6.txt
              {%- endif %}
      # https://github.com/pypa/pip/issues/9187
      # https://pip.pypa.io/en/stable/user_guide/#dependency-resolution-backtracking
      no_pips_deps: true  # for salt.virtualenv.managed.no_deps flag
      extras:
        # https://airflow.apache.org/docs/apache-airflow/stable/installation.html#extra-packages
        # https://airflow.apache.org/docs/apache-airflow/stable/extra-packages-ref.html
        # Services Extras
        - async
        - crypto
        - dask
        - datadog           # Datadog hooks and sensors
        - jira              # Jira hooks and operators
        - sendgrid          # Send email using sendgrid
        - slack             # airflow.providers.slack.operators.slack.SlackAPIOperator
        ## Software Extras
        - celery            # CeleryExecutor
        - cncf.kubernetes   # Kubernetes Executor and operator
        - docker            # Docker hooks and operators
        - ldap              # LDAP authentication for users
        - microsoft.azure
        - microsoft.mssql   # Microsoft SQL server
        - rabbitmq          # RabbitMQ support as a Celery backend
        - redis             # Redis hooks and sensors
        - statsd            # Needed by StatsD metrics
        - virtualenv
        ## Standard protocol Extras
        - cgroups           # Needed To use CgroupTaskRunner
        - grpc              # Grpc hooks and operators
        - http              # http hooks and providers
        - kerberos          # Kerberos integration
        - sftp
        - sqlite
        - ssh               # SSH hooks and Operator
        - microsoft.winrm   # WinRM hooks and operators


# https://github.com/saltstack-formulas/rabbitmq-formula/blob/master/pillar.example
rabbitmq:
  erlang_cookie: {{ my[domain]['name']|string }}-shared-secret
  nodes:
    rabbit:
      clustered: {{ 'false' if domain == 'localdomain' else 'true' }}
          {%- if grains.host == my.primaryhost|string %}
      join_node: rabbit@{{ my.secondaryhost|string }}
          {%- elif grains.host == my.secondaryhost|string %}
      join_node: rabbit@{{ my.primaryhost|string }}
          {%- elif grains.host == my[domain]['name']|string + '-worker01' %}
      join_node: rabbit@{{ my[domain]['name']|string }}-worker02
          {%- elif grains.host == my[domain]['name']|string + '-worker02' %}
      join_node: rabbit@{{ my[domain]['name']|string }}-worker01
          {%- endif %}
      config:
        # consumer_timeout = 1800000
        listeners.tcp.1: 0.0.0.0:5672
        auth_backends.1: internal
        # https://www.rabbitmq.com/ldap.html
        # auth_backends.2: ldap
        # auth_ldap.servers.1: {{ my[domain]['ldapserver']|string }}
        # auth_ldap.user_dn_pattern: cn=${username},{{ my[domain]['ldapbase']|string }}
        # auth_ldap.log: false
        # auth_ldap.dn_lookup_attribute: sAMAccountName  # or userPrincipalName
        # auth_ldap.dn_lookup_base: {{ my[domain]['ldapbase']|string }}
      service: true
      plugins:
        - rabbitmq_management
        - rabbitmq_federation
        - rabbitmq_federation_management
        - rabbitmq_auth_backend_ldap
        - rabbitmq_shovel
        - rabbitmq_shovel_management
      vhosts:
        - airflow
      remove_guest_user: true
      users:
        airflow:
          password: airflow
          force: true
          tags:
            - management
            - administrator
            - monitoring
            - user
          perms:
            '/':
              - '.*'
              - '.*'
              - '.*'
            airflow:
              - '.*'
              - '.*'
              - '.*'

        {%- set queues = my[domain]['queues'] %}
        {%- if my[domain] == 'main' %}
            {%- for wanted in my.domains %}
                {%- set queues = queues + my[wanted]['queues'] %}
            {%- endfor %}
        {%- endif %}

      queues:
        {%- for queue in queues %}

        {{ queue }}:
          user: airflow
          passwd: airflow
          durable: true
          auto_delete: false
          vhost: airflow
          arguments: {}
          # x-queue-type: quorum  # not supported by celery yet

        {%- endfor %}
        {%- if domain not in ['localdomain', 'main'] %}
            {%- for queue in queues %}
                {%- if loop.index0 == 0 %}
      parameters:
                {%- endif %}

        federation-upstream-queue-{{ domain }}-{{ queue }}:
          component: federation-upstream
          definition:
            uri: amqp://airflow:airflow@{{ my['loadbalancer']|string }}:5672
            trust-user-id: true
            ack-mode: on-confirm
            queue: {{ queue }}
            expires: 3600000
          vhost: airflow

            {%- endfor %}
            {%- for queue in queues %}
                {%- if loop.index0 == 0 %}
      policies:
                {%- endif %}
        policy-federation-upstream-queue-{{ domain }}-{{ queue }}:
          apply_to: queues
          pattern: ^{{ queue }}$
          priority: 1
          vhost: airflow
          definition:
            federation-upstream: federation-upstream-queue-{{ domain }}-{{ queue }}
                {%- if domain == queue %}
            ha-mode: exactly
            ha-params: 2
            ha-sync-mode: automatic
                {%- endif %}

            {%- endfor %}
        {%- endif %}

# https://github.com/saltstack-formulas/postgres-formula/blob/master/pillar.example
postgres:
  version: 13
  postgresconf: |-
    listen_addresses = '*'
  users:
    airflow:
      ensure: present
      password: airflow
      createdb: true
      inherit: true
      createroles: true
      replication: true
  databases:
    airflow:
      owner: airflow
  acls:
      # scope, db, user, [ cidr ] ..
    - ['local', 'airflow', 'airflow', 'md5']
    - ['local', 'all', 'all', 'peer']
    - ['host', 'all', 'all', '0.0.0.0/0', 'md5']
    - ['host', 'all', 'all', '::/0', 'md5']
    - ['host', 'all', 'all', '127.0.0.1/32', 'md5']
    - ['host', 'all', 'all', '::1/128', 'md5']
    - ['local', 'replication', 'all', 'peer']
    - ['host', 'replication', 'all', '127.0.0.1/32', 'md5']
    - ['host', 'replication', 'all', '::1/128', 'md5']
    - ['host', 'all', 'all', '10.145.40.151/32', 'md5']
    - ['host', 'all', 'all', '10.145.40.152/32', 'md5']
    - ['host', 'all', 'all', '10.48.41.0/24', 'md5']
    - ['host', 'all', 'all', '10.48.42.0/24', 'md5']
    - ['host', 'all', 'all', '10.58.41.0/24', 'md5']
    - ['host', 'all', 'all', '10.58.42.0/24', 'md5']
    - ['host', 'all', 'all', '10.61.41.0/24', 'md5']
    - ['host', 'all', 'all', '10.61.42.0/24', 'md5']

