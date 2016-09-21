{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}
glance-pkg-install:
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:glance', default='glance') }}"

glance-client-pkg-install:
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:python_glanceclient', default='python-glanceclient') }}"
    - require: 
        - pkg: glance-pkg-install

glance_registry_running:
  service: 
    - running
    - name: "{{ salt['pillar.get']('services:glance_registry') }}"
    - watch: 
      - pkg: glance-pkg-install
      - ini: glance-api-conf
      - ini: glance-registry-conf
      - cmd: glance_sync

glance_api_running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:glance_api') }}"
    - watch: 
      - pkg: glance-pkg-install
      - ini: glance-api-conf
      - ini: glance-registry-conf
      - cmd: glance_sync

glance-api-conf: 
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:glance_api', default="/etc/glance/glance-api.conf") }}"
    - mode: 644
    - user: glance
    - group: glance
    - require: 
        - pkg: glance-pkg-install
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:glance_api', default="/etc/glance/glance-api.conf") }}"
    - sections: 
        database: 
          connection: "mysql+pymysql://{{ salt['pillar.get']('databases:glance:username', default='glance') }}:{{ salt['pillar.get']('databases:glance:password', default='glance_pass') }}@{{ pillar['controller_cluster'] }}/{{ salt['pillar.get']('databases:glance:db_name', default='glance') }}"
        DEFAULT: 
          notification_driver: noop
        keystone_authtoken: 
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          auth_plugin: "password"
          project_domain_id: "default"
          user_domain_id: "default"
          project_name: "service"
          username: glance
          password: "{{ pillar['glance']['services']['glance']['users']['glance']['password'] }}"
        paste_deploy: 
          flavor: keystone
        glance_store: 
          default_store: file
          filesystem_store_datadir: /var/lib/glance/images/
    - require: 
        - file: glance-api-conf

glance-registry-conf: 
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:glance_registry', default="/etc/glance/glance-registry.conf") }}"
    - user: glance
    - group: glance
    - mode: 644
    - require: 
        - pkg: glance-pkg-install
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:glance_registry', default="/etc/glance/glance-registry.conf") }}"
    - sections: 
        database: 
          connection: "mysql+pymysql://{{ salt['pillar.get']('databases:glance:username', default='glance') }}:{{ salt['pillar.get']('databases:glance:password', default='glance_pass') }}@{{ pillar['controller_cluster'] }}/{{ salt['pillar.get']('databases:glance:db_name', default='glance') }}"
        DEFAULT: 
          notification_driver: noop
        keystone_authtoken: 
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          auth_plugin: "password"
          project_domain_id: "default"
          user_domain_id: "default"
          project_name: "service"
          username: glance
          password: "{{ pillar['glance']['services']['glance']['users']['glance']['password'] }}"
        paste_deploy: 
          flavor: keystone
    - require: 
        - file: glance-registry-conf

{% if 'db_sync' in salt['pillar.get']('databases:glance', default=()) %}
glance_sync: 
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:glance:db_sync') }}" glance'
    - require: 
        - pkg: glance-pkg-install
        - ini: glance-api-conf
        - ini: glance-registry-conf
{% endif %}

glance_sqlite_delete: 
  file: 
    - absent
    - name: /var/lib/glance/glance.sqlite
    - require: 
        - pkg: glance
