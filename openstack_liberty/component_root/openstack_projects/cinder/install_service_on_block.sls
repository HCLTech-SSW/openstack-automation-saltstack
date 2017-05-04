{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

lvm_pkg_install:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('packages:lvm', default='lvm2') }}

pv_create_disk_id:
  lvm:
    - pv_present
    - name: {{ pillar['blockstorage_drive'] }}
    - require:
      - pkg: lvm_pkg_install

vg_create_disk_id:
  lvm:
    - vg_present
    - name: {{ pillar['vg_name'] }}
    - devices: {{ pillar['blockstorage_drive'] }}
    - require:
      - lvm: pv_create_disk_id

cinder_volume_package:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:cinder_volume', default='cinder-volume') }}"
    - require:
      - pkg: lvm_pkg_install
   
python_mysqldb_package:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:python_mysqldb', default='python-mysqldb') }}"
    - require:
      - pkg: cinder_volume_package

cinder_config_file_volume:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:cinder', default='/etc/cinder/cinder.conf') }}"
    - user: cinder
    - group: cinder
    - mode: 644
    - require: 
      - ini: cinder_config_file_volume
  ini:
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:cinder', default='/etc/cinder/cinder.conf') }}"
    - sections:
        DEFAULT:
          rpc_backend: "{{ pillar['queue_engine'] }}"
          auth_strategy: keystone
          enabled_backends: lvm
          my_ip: {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','') }}
          glance_host: {{ pillar['controller_cluster'] }}
        lvm: 
          volume_driver: cinder.volume.drivers.lvm.LVMVolumeDriver
          volume_group: cinder-volumes
          iscsi_protocol: iscsi
          iscsi_helper: tgtadm
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
      - pkg: cinder_volume_package

tgt-service:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:tgt', default='tgt') }}"
    - watch:
      - file: cinder_config_file_volume

cinder_volume_service:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:cinder_volume', default='cinder-volume') }}"
    - watch:
      - service: tgt-service

cinder_sqlite_block_delete:
  file:
    - absent
    - name: /var/lib/cinder/cinder.sqlite
    - require:
        - service: cinder_volume_service
