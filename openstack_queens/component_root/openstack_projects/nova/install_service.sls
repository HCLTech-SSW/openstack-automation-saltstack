{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}
{% from "openstack_initial/systemInfo/system_resources.jinja" import ip4_interfaces with context %}

nova_api_install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_api', default='nova-api') }}"

nova_api_running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_api', default='nova-api') }}"
    - watch:
      - cmd: nova_manage_verify

nova_conductor_install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_conductor', default='nova-conductor') }}"
    - require:
      - pkg: nova_api_install

nova_conductor_running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_conductor', default='nova-conductor') }}"
    - watch:
      - service: nova_scheduler_running

nova_scheduler_install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_scheduler', default='nova-scheduler') }}"
    - require:
      - pkg: nova_novncproxy_install

nova_scheduler_running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_scheduler', default='nova-scheduler') }}"
    - watch:
      - service: nova_consoleauth_running

nova_consoleauth_install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_consoleauth', default='nova-consoleauth') }}"
    - require:
      - pkg: nova_conductor_install

nova_consoleauth_running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_consoleauth', default='nova-consoleauth') }}"
    - watch:
      - service: nova_api_running

nova_novncproxy_install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_novncproxy', default='nova-novncproxy') }}"
    - require:
      - pkg: nova_consoleauth_install

nova_novncproxy_running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_novncproxy', default='nova-novncproxy') }}"
    - watch:
      - service: nova_scheduler_running

{% if 'db_sync' in salt['pillar.get']('databases:nova_api', default=()) %}
nova_api_sync: 
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:nova_api:db_sync') }}" nova'
    - require: 
        - pkg: nova_api_install
        - pkg: nova_conductor_install
        - pkg: nova_scheduler_install
        - pkg: nova_consoleauth_install
        - pkg: nova_novncproxy_install
        - file: nova_conf
{% endif %}

{% if 'cell0_register' in salt['pillar.get']('databases:nova_cell0', default=()) %}
nova_cell0_register:
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:nova_cell0:cell0_register') }}" nova'
    - require: 
        - cmd: nova_api_sync
{% endif %}

{% if 'cell1_create' in salt['pillar.get']('databases:nova_cell0', default=()) %}
nova_cell1_create: 
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:nova_cell0:cell1_create') }}" nova 109e1d4b-536a-40d0-83c6-5f121b82b650'
    - require: 
        - cmd: nova_cell0_register
{% endif %}

{% if 'db_sync' in salt['pillar.get']('databases:nova', default=()) %}
nova_sync: 
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:nova:db_sync') }}" nova'
    - require: 
        - cmd: nova_cell1_create
{% endif %}

nova_conf:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}"
    - user: nova
    - group: nova
    - mode: 644
    - require:
      - ini: nova_conf
  ini:
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}"
    - sections: 
        DEFAULT: 
          transport_url: "rabbit://openstack:rabbit123@{{ pillar['controller_cluster'] }}"
{% for ipv4 in ip4_interfaces %}
          my_ip: "{{ ipv4 }}"
{% endfor %}
          firewall_driver: "nova.virt.firewall.NoopFirewallDriver"
          use_neutron: true
        api: 
          auth_strategy : "keystone"
        vnc:
          enabled: true
          server_listen: "$my_ip"
          server_proxyclient_address: "$my_ip"
        glance: 
          api_servers: "http://{{ pillar['controller_cluster'] }}:9292"
        oslo_concurrency: 
          lock_path: /var/lib/nova/tmp
        keystone_authtoken: 
          auth_url: "http://{{ pillar['controller_cluster'] }}:5000/v3"
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
        placement: 
          os_region_name: "{{ pillar['common_keys']['bootstrap_regionid'] }}"
          project_domain_name: "default"
          project_name: "service"
          auth_type: "password"
          user_domain_name: "default"
          auth_url: "http://{{ pillar['controller_cluster'] }}:5000/v3"
          username: placement
          password: "{{ pillar['nova']['services']['placement']['users']['placement']['password'] }}"
        scheduler:
          discover_hosts_in_cells_interval: 300
    - require:
      - pkg: nova_placement_api_install
  
nova_placement_api_install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_placement_api', default='nova-placement-api') }}"
    - require:
      - pkg: nova_scheduler_install

nova_manage_verify: 
  cmd: 
    - run
    - name: 'nova-manage cell_v2 list_cells'
    - require: 
        - cmd: nova_sync
