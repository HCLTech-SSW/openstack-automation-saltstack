rabbitmq-server-install:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('packages:rabbitmq', default='rabbitmq-server') }}
rabbitmq-service-running:
  service:
    - running
    - name: {{ salt['pillar.get']('services:rabbitmq', default='rabbitmq') }}
    - watch:
      - pkg: rabbitmq-server-install
rabbit_user:
  rabbitmq_user.present:
    - name: openstack
    - password: rabbit123
    - force: True
    - perms:
      - '/':
        - '.*'
        - '.*'
        - '.*'
    - require:
      - pkg: rabbitmq-server-install

