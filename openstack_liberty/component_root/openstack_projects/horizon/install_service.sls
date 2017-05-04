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
    - pattern: '^#OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = False$'
    - repl: 'OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True'
    - require: 
      - file: change-2-dashboard-settings

change-4-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: '^#OPENSTACK_API_VERSIONS = {$'
    - repl: 'OPENSTACK_API_VERSIONS = {'
    - require: 
      - file: change-3-dashboard-settings

change-5-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: '^#[\s]*"data-processing": 1.1,$'
    - repl: '    "data-processing": 1.1,'
    - require: 
      - file: change-4-dashboard-settings

change-6-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: '^#[\s]*"identity": 3,$'
    - repl: '    "identity": 3,'
    - require: 
      - file: change-5-dashboard-settings

change-7-dashboard-settings:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:openstack_dashboard_conf', default='/etc/openstack-dashboard/local_settings.py') }}"
    - backup: False
    - pattern: '^#[\s]*"volume": 2,$'
    - repl: '    "volume": 2, }'
    - require: 
      - file: change-6-dashboard-settings

service-apache-reload:
  cmd:
    - run
    - name: "service apache2 reload"
    - require: 
      - file: change-7-dashboard-settings

