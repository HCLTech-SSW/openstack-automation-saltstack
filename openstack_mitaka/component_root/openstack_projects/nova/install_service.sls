{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

nova-api-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_api', default='nova-api') }}"

nova-api-running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_api', default='nova-api') }}"
    - watch:
      - cmd: nova_sync

nova-conductor-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_conductor', default='nova-conductor') }}"
    - require:
      - pkg: nova-api-install

nova-conductor-running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_conductor', default='nova-conductor') }}"
    - watch:
      - service: nova-scheduler-running

nova-scheduler-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_scheduler', default='nova-scheduler') }}"
    - require:
      - pkg: nova-novncproxy-install

nova-scheduler-running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_scheduler', default='nova-scheduler') }}"
    - watch:
      - service: nova-consoleauth-running

nova-consoleauth-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_consoleauth', default='nova-consoleauth') }}"
    - require:
      - pkg: nova-conductor-install

nova-consoleauth-running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_consoleauth', default='nova-consoleauth') }}"
    - watch:
      - service: nova-api-running

nova-novncproxy-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_novncproxy', default='nova-novncproxy') }}"
    - require:
      - pkg: nova-consoleauth-install

nova-novncproxy-running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_novncproxy', default='nova-novncproxy') }}"
    - watch:
      - service: nova-scheduler-running

{% if 'db_sync' in salt['pillar.get']('databases:nova_api', default=()) %}
nova_api_sync: 
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:nova_api:db_sync') }}" nova'
    - require: 
        - pkg: nova-api-install
        - pkg: nova-conductor-install
        - pkg: nova-scheduler-install
        - pkg: nova-consoleauth-install
        - pkg: nova-novncproxy-install
        - file: nova-conf
{% endif %}

{% if 'db_sync' in salt['pillar.get']('databases:nova', default=()) %}
nova_sync: 
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:nova:db_sync') }}" nova'
    - require: 
        - cmd: nova_api_sync
{% endif %}

nova-pre-conf-file_controller:
  file: 
    - managed
    - name: {{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}
    - user: nova
    - password: nova
    - mode: 644
    - require: 
      - ini: nova-pre-conf-file_controller
  ini: 
    - sections_absent
    - name: {{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}
    - sections: 
        keystone_authtoken:
          - identity_uri
          - admin_tenant_name
          - admin_user
          - admin_password
    - require: 
      - pkg: nova-scheduler-install

nova-conf:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}"
    - user: nova
    - group: nova
    - mode: 644
    - require:
      - ini: nova-conf
  ini:
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}"
    - sections: 
        DEFAULT: 
          enabled_apis: "osapi_compute,metadata"
          rpc_backend: "{{ pillar['queue_engine'] }}"
          auth_strategy: "keystone"
          my_ip: {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','') }}
          firewall_driver: "nova.virt.firewall.NoopFirewallDriver"
          use_neutron: True
        oslo_messaging_rabbit: 
          rabbit_host: "{{ pillar['controller_cluster'] }}"
          rabbit_userid: "openstack"
          rabbit_password: "rabbit123"
        vnc: 
          vncserver_listen: "$my_ip"
          vncserver_proxyclient_address: "$my_ip"
        glance: 
          api_servers: "http://{{ pillar['controller_cluster'] }}:9292"
        oslo_concurrency: 
          lock_path: /var/lib/nova/tmp
        keystone_authtoken: 
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          memcached_servers: "{{ pillar['controller_cluster'] }}:11211"
          auth_type: "password"
          project_domain_name: "default"
          user_domain_name: "default"
          project_name: "service"
          username: nova
          password: "{{ pillar['nova']['services']['nova']['users']['nova']['password'] }}"
        database: 
          connection: "mysql+pymysql://{{ salt['pillar.get']('databases:nova:username', default='nova') }}:{{ salt['pillar.get']('databases:nova:password', default='nova_pass') }}@{{ pillar['controller_cluster'] }}/{{ salt['pillar.get']('databases:nova:db_name', default='nova') }}"
        api_database: 
          connection: "mysql+pymysql://{{ salt['pillar.get']('databases:nova_api:username', default='nova') }}:{{ salt['pillar.get']('databases:nova_api:password', default='nova_pass') }}@{{ pillar['controller_cluster'] }}/{{ salt['pillar.get']('databases:nova_api:db_name', default='nova_api') }}"
    - require:
      - file: nova-pre-conf-file_controller
