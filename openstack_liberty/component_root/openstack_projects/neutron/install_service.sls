{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

neutron-server-install: 
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:neutron_server', default='neutron-server') }}"

neutron-pre-conf-file:
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:neutron', default='/etc/neutron/neutron.conf') }}"
    - user: neutron
    - group: neutron
    - mode: 644
    - require: 
      - pkg: neutron-server-install
  ini: 
    - sections_absent
    - name: "{{ salt['pillar.get']('conf_files:neutron', default='/etc/neutron/neutron.conf') }}"
    - sections: 
        keystone_authtoken:
          - identity_uri
          - admin_tenant_name
          - admin_user
          - admin_password
    - require: 
      - file: neutron-conf-file 

neutron-conf-file:
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:neutron', default='/etc/neutron/neutron.conf') }}"
    - user: neutron
    - group: neutron
    - mode: 644
    - require: 
      - file: neutron-pre-conf-file
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:neutron', default='/etc/neutron/neutron.conf') }}"
    - sections: 
        DEFAULT: 
          core_plugin: ml2
          service_plugins: router
          allow_overlapping_ips: True
          rpc_backend: "{{ pillar['queue_engine'] }}"
          auth_strategy: keystone
          notify_nova_on_port_status_changes: True
          notify_nova_on_port_data_changes: True
          nova_url: "http://{{ pillar['controller_cluster'] }}:8774/v2"
        oslo_messaging_rabbit: 
          rabbit_host: "{{ pillar['controller_cluster'] }}"
          rabbit_userid: "openstack"
          rabbit_password: "rabbit123"
        keystone_authtoken: 
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          auth_plugin: "password"
          project_domain_id: "default"
          user_domain_id: "default"
          project_name: "service"
          username: neutron
          password: "{{ pillar['neutron']['services']['neutron']['users']['neutron']['password'] }}"
        nova: 
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          auth_plugin: "password"
          project_domain_id: "default"
          user_domain_id: "default"
          region_name: "RegionOne"
          project_name: "service"
          username: nova
          password: "{{ pillar['nova']['services']['nova']['users']['nova']['password'] }}"
        database: 
          connection: "mysql+pymysql://{{ salt['pillar.get']('databases:neutron:username', default='neutron') }}:{{ salt['pillar.get']('databases:neutron:password', default='neutron_pass') }}@{{ pillar['controller_cluster'] }}/{{ salt['pillar.get']('databases:neutron:db_name', default='neutron') }}"  
    - require: 
      - file: neutron-conf-file
