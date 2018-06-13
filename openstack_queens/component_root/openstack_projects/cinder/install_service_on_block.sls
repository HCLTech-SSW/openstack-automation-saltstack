{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}
{% from "openstack_initial/systemInfo/system_resources.jinja" import ip4_interfaces with context %}

lvm_pkg_install:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('packages:lvm', default='lvm2') }}

thin_provisioning_tools_pkg_install:
  pkg:
    - installed
    - name: {{ salt['pillar.get']('packages:thin_provisioning_tools', default='thin-provisioning-tools') }}
    - require:
      - pkg: lvm_pkg_install

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
      - lvm: vg_create_disk_id
   
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
          transport_url: "rabbit://openstack:rabbit123@{{ pillar['controller_cluster'] }}"
          auth_strategy: keystone
          enabled_backends: lvm
{% for ipv4 in ip4_interfaces %}
          my_ip: "{{ ipv4 }}"
{% endfor %}
          glance_api_servers: "http://{{ pillar['controller_cluster'] }}:9292"
        lvm: 
          volume_driver: cinder.volume.drivers.lvm.LVMVolumeDriver
          volume_group: cinder-volumes
          iscsi_protocol: iscsi
          iscsi_helper: tgtadm
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
      - pkg: cinder_volume_package

tgt_service:
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
      - service: tgt_service
