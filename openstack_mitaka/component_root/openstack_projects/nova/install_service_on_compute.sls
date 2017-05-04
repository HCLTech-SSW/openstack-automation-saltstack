{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

nova-compute-install:
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:nova_compute', default='nova-compute') }}

nova-compute-running:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:nova_compute', default='nova-compute') }}
    - watch: 
      - file: nova-conf-compute
      - ini: nova-conf-compute

nova-compute-conf:
  file: 
    - managed
    - name: {{ salt['pillar.get']('conf_files:nova_compute', default='/etc/nova/nova-compute.conf') }}
    - user: nova
    - group: nova
    - mode: 644
    - require: 
      - ini: nova-compute-conf
  ini: 
    - options_present
    - name: {{ salt['pillar.get']('conf_files:nova_compute', default='/etc/nova/nova-compute.conf') }}
    - sections: 
        libvirt: 
{% if 'virt.is_hyper' %}
          virt_type: kvm
{% else %}
          virt_type: qemu
{% endif %}
    - require: 
      - pkg: nova-compute-install

nova-conf-compute: 
  file: 
    - managed
    - name: {{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}
    - user: nova
    - password: nova
    - mode: 644
    - require: 
      - ini: nova-conf-compute
  ini: 
    - options_present
    - name: {{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}
    - sections: 
        DEFAULT: 
          rpc_backend: "{{ pillar['queue_engine'] }}"
          auth_strategy: "keystone"
          my_ip: {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','') }}
          firewall_driver: "nova.virt.firewall.NoopFirewallDriver"
          use_neutron: True
        oslo_messaging_rabbit: 
          rabbit_host: "{{ pillar['controller_cluster'] }}"
          rabbit_userid: "openstack"
          rabbit_password: "rabbit123"
        vnc: 
          enabled: "True"
          vncserver_listen: "0.0.0.0"
          vncserver_proxyclient_address: "$my_ip"
          novncproxy_base_url: "http://{{ pillar['controller_cluster'] }}:6080/vnc_auto.html"
        glance: 
          api_servers: "http://{{ pillar['controller_cluster'] }}:9292"
        oslo_concurrency: 
          lock_path: /var/lib/nova/tmp
        keystone_authtoken: 
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          memcached_servers: "{{ pillar['controller_cluster'] }}:11211"
          auth_type: "password"
          project_domain_name: "default"
          user_domain_name: "default"
          project_name: "service"
          username: nova
          password: "{{ pillar['nova']['services']['nova']['users']['nova']['password'] }}"
    - require: 
      - file: nova-pre-conf-file_compute

nova-pre-conf-file_compute:
  file: 
    - managed
    - name: {{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}
    - user: nova
    - password: nova
    - mode: 644
    - require: 
      - ini: nova-pre-conf-file_compute
  ini: 
    - sections_absent
    - name: {{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}
    - sections: 
        keystone_authtoken:
          - identity_uri
          - admin_tenant_name
          - admin_user
          - admin_password
    - require: 
      - pkg: nova-compute-install
      - file: nova-compute-conf
