{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

keystone_pkg_install: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:keystone', default='keystone') }}

keystone_conf_file:
    file: 
      - managed
      - name: {{ salt['pillar.get']('conf_files:keystone', default='/etc/keystone/keystone.conf') }}
      - user: root
      - group: root
      - mode: 644
      - require: 
          - pkg: keystone_pkg_install
    ini: 
      - options_present
      - name: {{ salt['pillar.get']('conf_files:keystone', default='/etc/keystone/keystone.conf') }}
      - sections: 
          database: 
            connection: mysql+pymysql://{{ salt['pillar.get']('databases:keystone:username', default='keystone') }}:{{ salt['pillar.get']('databases:keystone:password', default='keystone_pass') }}@{{ pillar['controller_cluster'] }}/{{ salt['pillar.get']('databases:keystone:db_name', default='keystone') }}
          token: 
            provider: fernet
      - require: 
          - file: keystone_conf_file

{% if 'db_sync' in salt['pillar.get']('databases:keystone', default=()) %}
keystone_sync: 
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:keystone:db_sync') }}" keystone'
{% endif %}

apache_service_keystone:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:apache', default='apache2') }}
    - require: 
      - cmd: keystone_sync
      - cmd: keystone_manage_fernet
      - cmd: keystone_bootstrap

python_openstackclient_pkg_install: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:python_openstackclient', default='python-openstackclient') }}
    - require: 
      - pkg: keystone_pkg_install

keystone_manage_fernet: 
  cmd: 
    - run
    - name: 'keystone-manage fernet_setup --keystone-user {{ salt['pillar.get']('databases:keystone:db_name', default='keystone') }} --keystone-group {{ salt['pillar.get']('databases:keystone:db_name', default='keystone') }} && keystone-manage credential_setup --keystone-user {{ salt['pillar.get']('databases:keystone:db_name', default='keystone') }} --keystone-group {{ salt['pillar.get']('databases:keystone:db_name', default='keystone') }}'
    - require:
      - cmd: keystone_sync

keystone_bootstrap: 
  cmd: 
    - run
    - name: 'keystone-manage bootstrap --bootstrap-password {{ pillar['common_keys']['os_password'] }} --bootstrap-admin-url {{ pillar['common_keys']['bootstrap_adminurl'].format(pillar['controller_cluster']) }} --bootstrap-internal-url {{ pillar['common_keys']['bootstrap_internalurl'].format(pillar['controller_cluster']) }} --bootstrap-public-url {{ pillar['common_keys']['bootstrap_publicurl'].format(pillar['controller_cluster']) }} --bootstrap-region-id {{ pillar['common_keys']['bootstrap_regionid'] }}'
    - require:
      - cmd: keystone_manage_fernet
