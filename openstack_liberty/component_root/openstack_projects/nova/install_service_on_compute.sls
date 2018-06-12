{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

sysfsutils-install: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:sys_fsutils', default='sysfsutils') }}
    - require: 
      - pkg: nova-compute-install

nova-compute-install:
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:nova_compute', default='nova-compute') }}

nova-compute-running:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:nova_compute', default='nova-compute') }}
    - watch: 
      - pkg: nova-compute-install
      - file: nova-conf-compute
      - ini: nova-conf-compute
      - file: nova-compute-conf
      - ini: nova-compute-conf

nova_sqlite_delete:
  file:
    - absent
    - name: /var/lib/nova/nova.sqlite
    - require:
      - pkg: nova-compute-install
      - service: nova-compute-running

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
          network_api_class: "nova.network.neutronv2.api.API"
          security_group_api: "neutron"
          linuxnet_interface_driver: "nova.network.linux_net.NeutronLinuxBridgeInterfaceDriver"
          firewall_driver: "nova.virt.firewall.NoopFirewallDriver"
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
          host: "{{ pillar['controller_cluster'] }}"
        oslo_concurrency: 
          log_path: /var/lib/nova/tmp
        keystone_authtoken: 
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          auth_plugin: "password"
          project_domain_id: "default"
          user_domain_id: "default"
          project_name: "service"
          username: nova
          password: "{{ pillar['nova']['services']['nova']['users']['nova']['password'] }}"
    - require: 
      - pkg: nova-compute-install

nova-instance-directory: 
  file: 
    - directory
    - name: /var/lib/nova/instances/
    - user: nova
    - group: nova
    - mode: 755
    - recurse: 
      - user
      - group
      - mode
    - require: 
      - pkg: nova-compute-install
