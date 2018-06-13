{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

openstack-dashboard-install: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:dashboard', default='openstack-dashboard') }}

change-1-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: 'OPENSTACK_HOST = "127.0.0.1"'
    - repl: 'OPENSTACK_HOST = "{{ pillar['controller_cluster'] }}"'
    - require: 
      - pkg: openstack-dashboard-install

change-2-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: 'OPENSTACK_KEYSTONE_DEFAULT_ROLE = "_member_"'
    - repl: 'OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"'
    - require: 
      - file: change-1-dashboard-settings

change-3-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: 'OPENSTACK_KEYSTONE_URL = "http://%s:5000/v2.0" % OPENSTACK_HOST'
    - repl: 'OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST'
    - require: 
      - file: change-2-dashboard-settings

change-4-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: '^#OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = False$'
    - repl: 'OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True'
    - require: 
      - file: change-3-dashboard-settings

change-5-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: "^#OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = 'default'$"
    - repl: 'OPENSTACK_KEYSTONE_DEFAULT_SUPPORT = "default"'
    - require: 
      - file: change-4-dashboard-settings

change-6-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: '^#OPENSTACK_API_VERSIONS = {$'
    - repl: 'OPENSTACK_API_VERSIONS = {'
    - require: 
      - file: change-5-dashboard-settings

change-7-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: '^#[\s]*"identity": 3,$'
    - repl: '    "identity": 3,     "image":2,'
    - require: 
      - file: change-6-dashboard-settings

change-8-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: '^#[\s]*"volume": 2,$'
    - repl: '    "volume": 2, }'
    - require: 
      - file: change-7-dashboard-settings

change-9-dashboard-settings:
  file:
    - append
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - text: SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
    - require:
      - file: change-8-dashboard-settings

change-10-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: "^[ ]*'LOCATION': '127.0.0.1:11211',$"
    - repl: "  'LOCATION': '{{ pillar['controller_cluster'] }}:11211',"
    - require:
      - file: change-9-dashboard-settings

update-dashboard-conf-settings:
  file:
    - append
    - name: "{{ salt['pillar.get']('conf_files:openstack_conf', default='/etc/apache2/conf-available/openstack-dashboard.conf') }}"
    - text: WSGIApplicationGroup %{GLOBAL}
    - require:
      - file: change-10-dashboard-settings

memcached-service_reload:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:memcached', default='memcached') }}
    - require: 
      - cmd: update-dashboard-conf-settings

service-apache-reload:
  cmd:
    - run
    - name: "service apache2 reload"
    - require: 
      - service: memcached-service_reload

