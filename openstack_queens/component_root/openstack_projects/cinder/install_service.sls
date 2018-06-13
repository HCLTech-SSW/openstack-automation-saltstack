{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}
{% from "openstack_initial/systemInfo/system_resources.jinja" import ip4_interfaces with context %}

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
          auth_strategy: keystone
          transport_url: "rabbit://openstack:rabbit123@{{ pillar['controller_cluster'] }}"
{% for ipv4 in ip4_interfaces %}
          my_ip: "{{ ipv4 }}"
{% endfor %}
        oslo_concurrency: 
          lock_path: /var/lib/cinder/tmp
        database:
          connection: "mysql+pymysql://{{ salt['pillar.get']('databases:cinder:username', default='cinder') }}:{{ salt['pillar.get']('databases:cinder:password', default='cinder_pass') }}@{{ pillar['controller_cluster'] }}/{{ salt['pillar.get']('databases:cinder:db_name', default='cinder') }}"
        keystone_authtoken: 
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:5000"
          memcached_servers: "{{ pillar['controller_cluster'] }}:11211"
          auth_type: "password"
          project_domain_name: "default"
          user_domain_name: "default"
          project_name: "service"
          username: cinder
          password: "{{ pillar['cinder']['services']['cinder']['users']['cinder']['password'] }}"
    - require:
      - pkg: cinder_api_pkg
      - pkg: cinder_scheduler_pkg

{% if 'db_sync' in salt['pillar.get']('databases:cinder', default=()) %}
cinder_sync:
  cmd:
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:cinder:db_sync') }}" cinder'
    - require:
      - file: cinder_config_file
{% endif %}

nova_cinder_conf:
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
          os_region_name: {{ pillar['nova']['services']['nova']['endpoint']['region'] }}
    - require: 
      - cmd: cinder_sync

nova_api_re_running:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:nova_api', default='nova-api') }}
    - watch: 
      - cmd: cinder_sync
      - file: nova_cinder_conf

cinder_scheduler_service:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:cinder_scheduler', default='cinder-scheduler') }}"
    - watch:
      - service: nova_api_re_running
      - file: cinder_config_file

cinder_apache2_reload:
  cmd:
    - run
    - name: "service apache2 reload"
    - require: 
      - service: cinder_scheduler_service
