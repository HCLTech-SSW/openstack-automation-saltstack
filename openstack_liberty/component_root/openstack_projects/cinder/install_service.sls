{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

cinder_api_pkg:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:cinder_api', default='cinder-api') }}"

cinder_scheduler_pkg:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:cinder_scheduler', default='cinder-scheduler') }}"
    - require: 
      - pkg: cinder_api_pkg

cinder_client_pkg:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:cinder_client', default='python-cinderclient') }}"
    - require: 
      - pkg: cinder_scheduler_pkg

cinder_config_file:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:cinder', default='/etc/cinder/cinder.conf') }}"
    - user: cinder
    - group: cinder
    - mode: 644
    - require: 
      - ini: cinder_config_file
  ini:
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:cinder', default='/etc/cinder/cinder.conf') }}"
    - sections:
        DEFAULT:
          rpc_backend: "{{ pillar['queue_engine'] }}"
          auth_strategy: keystone
          my_ip: {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','') }}
        oslo_concurrency: 
          lock_path: /var/lib/cinder/tmp
        oslo_messaging_rabbit: 
          rabbit_host: "{{ pillar['controller_cluster'] }}"
          rabbit_userid: "openstack"
          rabbit_password: "rabbit123"
        database:
          connection: "mysql+pymysql://{{ salt['pillar.get']('databases:cinder:username', default='cinder') }}:{{ salt['pillar.get']('databases:cinder:password', default='cinder_pass') }}@{{ pillar['controller_cluster'] }}/{{ salt['pillar.get']('databases:cinder:db_name', default='cinder') }}"
        keystone_authtoken:
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          auth_plugin: "password"
          project_domain_id: "default"
          user_domain_id: "default"
          project_name: "service"
          username: cinder
          password: "{{ pillar['cinder']['services']['cinder']['users']['cinder']['password'] }}"
    - require:
      - pkg: cinder_api_pkg
      - pkg: cinder_scheduler_pkg
      - pkg: cinder_client_pkg

nova-cinder-conf:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}"
    - user: nova
    - group: nova
    - mode: 644
    - require:
      - file: cinder_config_file
  ini:
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}"
    - sections: 
        cinder:
          os_region_name: {{ pillar['cinder']['services']['cinder']['endpoint']['region'] }}
    - require: 
      - file: nova-cinder-conf

{% if 'db_sync' in salt['pillar.get']('databases:cinder', default=()) %}
cinder_sync:
  cmd:
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:cinder:db_sync') }}" cinder'
    - require:
      - file: cinder_config_file
      - file: nova-cinder-conf
{% endif %}

nova-api-re-running:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:nova_api', default='nova-api') }}
    - watch: 
      - cmd: cinder_sync

cinder-scheduler-service:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:cinder_scheduler', default='cinder-scheduler') }}"
    - watch:
      - service: nova-api-re-running
      - file: cinder_config_file

cinder-api-service:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:cinder_api', default='cinder-api') }}"
    - watch:
      - service: cinder-scheduler-service
      - file: cinder_config_file

cinder_sqlite_delete:
  file:
    - absent
    - name: /var/lib/cinder/cinder.sqlite
    - require:
        - service: cinder-api-service

