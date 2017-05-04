{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

keystone-pkg-install: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:keystone', default='keystone') }}

keystone-conf-file:
    file: 
      - managed
      - name: {{ salt['pillar.get']('conf_files:keystone', default='/etc/keystone/keystone.conf') }}
      - user: root
      - group: root
      - mode: 644
      - require: 
          - pkg: keystone-pkg-install
    ini: 
      - options_present
      - name: {{ salt['pillar.get']('conf_files:keystone', default='/etc/keystone/keystone.conf') }}
      - sections: 
          DEFAULT: 
            admin_token: {{ salt['pillar.get']('common_keys:admin_token', default='ADMIN') }}
          database: 
            connection: mysql+pymysql://{{ salt['pillar.get']('databases:keystone:username', default='keystone') }}:{{ salt['pillar.get']('databases:keystone:password', default='keystone_pass') }}@{{ pillar['controller_cluster'] }}/{{ salt['pillar.get']('databases:keystone:db_name', default='keystone') }}
          token: 
            provider: fernet
      - require: 
          - file: keystone-conf-file

{% if 'db_sync' in salt['pillar.get']('databases:keystone', default=()) %}
keystone_sync: 
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:keystone:db_sync') }}" keystone'
{% endif %}

apache-service_keystone:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:apache', default='apache2') }}
    - require: 
      - cmd: keystone_sync
      - cmd: keystone_manage_fernet

keystone_sqlite_delete: 
  file: 
    - absent
    - name: /var/lib/keystone/keystone.db
    - require: 
      - service: apache-service_keystone
      - pkg: keystone-pkg-install

python-openstackclient-pkg-install: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:python_openstackclient', default='python-openstackclient') }}
    - require: 
      - pkg: keystone-pkg-install

keystone_manage_fernet: 
  cmd: 
    - run
    - name: 'keystone-manage fernet_setup --keystone-user {{ salt['pillar.get']('databases:keystone:db_name', default='keystone') }} --keystone-group {{ salt['pillar.get']('databases:keystone:db_name', default='keystone') }}'
    - require:
      - cmd: keystone_sync
