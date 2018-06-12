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
      - pkg: nova-api-install
      - ini: nova-conf
      - file: nova-conf
      - cmd: nova_sync

nova-conductor-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_conductor', default='nova-conductor') }}"

nova-conductor-running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_conductor', default='nova-conductor') }}"
    - watch:
      - pkg: nova-conductor-install
      - ini: nova-conf
      - file: nova-conf
      - service: nova-scheduler-running

nova-scheduler-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_scheduler', default='nova-scheduler') }}"

nova-scheduler-running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_scheduler', default='nova-scheduler') }}"
    - watch:
      - pkg: nova-scheduler-install
      - ini: nova-conf
      - file: nova-conf
      - service: nova-consoleauth-running

nova-cert-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_cert', default='nova-cert') }}"

nova-cert-running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_cert', default='nova-cert') }}"
    - watch:
      - pkg: nova-cert-install
      - ini: nova-conf
      - file: nova-conf
      - service: nova-api-running

nova-consoleauth-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_consoleauth', default='nova-consoleauth') }}"

nova-consoleauth-running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_consoleauth', default='nova-consoleauth') }}"
    - watch:
      - pkg: nova-consoleauth-install
      - ini: nova-conf
      - file: nova-conf
      - service: nova-cert-running

python-novaclient:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_pythonclient', default='python-novaclient') }}"

nova-novncproxy-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_novncproxy', default='nova-novncproxy') }}"

nova-novncproxy-running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_novncproxy', default='nova-novncproxy') }}"
    - watch:
      - pkg: nova-novncproxy-install
      - ini: nova-conf
      - file: nova-conf
      - service: nova-conductor-running

{% if 'db_sync' in salt['pillar.get']('databases:nova', default=()) %}
nova_sync: 
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:nova:db_sync') }}" nova'
    - require: 
        - pkg: nova-api-install
        - pkg: nova-conductor-install
        - pkg: nova-scheduler-install
        - pkg: nova-cert-install
        - pkg: nova-consoleauth-install
        - pkg: nova-novncproxy-install
        - pkg: python-novaclient
        - ini: nova-conf
{% endif %}

nova_sqlite_delete:
  file:
    - absent
    - name: /var/lib/nova/nova.sqlite
    - require:
      - pkg: nova-api
      - service: nova-novncproxy-running

nova-conf:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}"
    - user: nova
    - group: nova
    - mode: 644
    - require:
      - pkg: nova-api
      - ini: nova-conf
  ini:
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}"
    - sections: 
        DEFAULT: 
          rpc_backend: "{{ pillar['queue_engine'] }}"
          auth_strategy: "keystone"
          my_ip: {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','') }}
          network_api_class: "nova.network.neutronv2.api.API"
          security_group_api: "neutron"
          linuxnet_interface_driver: "nova.network.linux_net.NeutronLinuxBridgeInterfaceDriver"
          firewall_driver: "nova.virt.firewall.NoopFirewallDriver"
          enabled_apis: "osapi_compute,metadata"
        oslo_messaging_rabbit: 
          rabbit_host: "{{ pillar['controller_cluster'] }}"
          rabbit_userid: "openstack"
          rabbit_password: "rabbit123"
        vnc: 
          vncserver_listen: "$my_ip"
          vncserver_proxyclient_address: "$my_ip"
        glance: 
          host: "{{ pillar['controller_cluster'] }}"
        oslo_concurrency: 
          log_path: /var/lib/nova/tmp
        keystone_authtoken: 
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          auth_plugin: "password"
          project_domain_id: "default"
          user_domain_id: "default"
          project_name: "service"
          username: nova
          password: "{{ pillar['nova']['services']['nova']['users']['nova']['password'] }}"
        database: 
          connection: "mysql+pymysql://{{ salt['pillar.get']('databases:nova:username', default='nova') }}:{{ salt['pillar.get']('databases:nova:password', default='nova_pass') }}@{{ pillar['controller_cluster'] }}/{{ salt['pillar.get']('databases:nova:db_name', default='nova') }}"
    - require:
      - pkg: nova-api-install
