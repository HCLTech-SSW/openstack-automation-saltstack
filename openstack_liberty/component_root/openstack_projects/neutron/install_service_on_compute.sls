{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}
{% from "openstack_initial/systemInfo/physical_networks.jinja" import bridges with context %}

neutron-linuxbridge-agent-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:neutron_plugin_linuxbridge_agent', default='neutron-plugin-linuxbridge-agent') }}"

conntrack-install: 
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:conntrack', default='conntrack') }}"
    - require: 
      - pkg: neutron-linuxbridge-agent-install

neutron-pre-compute-conf-file:
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:neutron', default='/etc/neutron/neutron.conf') }}"
    - user: neutron
    - group: neutron
    - mode: 644
    - require: 
      - pkg: conntrack-install
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
      - file: neutron-pre-compute-conf-file 

neutron-conf-file:
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:neutron', default='/etc/neutron/neutron.conf') }}"
    - user: neutron
    - group: neutron
    - mode: 644
    - require: 
      - file: neutron-pre-compute-conf-file
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:neutron', default='/etc/neutron/neutron.conf') }}"
    - sections: 
        DEFAULT: 
          rpc_backend: "{{ pillar['queue_engine'] }}"
          auth_strategy: keystone
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
    - require: 
      - file: neutron-conf-file

nova-conf:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}"
    - user: nova
    - group: nova
    - mode: 644
    - require:
      - file: neutron-conf-file
  ini:
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}"
    - sections: 
        neutron:
          url: "http://{{ pillar['controller_cluster'] }}:9696"
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          auth_plugin: "password"
          project_domain_id: "default"
          user_domain_id: "default"
          region_name: "RegionOne"
          project_name: "service"
          username: neutron
          password: "{{ pillar['neutron']['services']['neutron']['users']['neutron']['password'] }}"
    - require: 
      - file: nova-conf

linuxbridge-agent-config-file:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:neutron_linuxbridge_agent', default='/etc/neutron/plugins/ml2/linuxbridge_agent.ini') }}"
    - user: neutron
    - group: neutron
    - mode: 644
    - require:
      - file: neutron-conf-file
      - file: nova-conf
  ini:
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:neutron_linuxbridge_agent', default='/etc/neutron/plugins/ml2/linuxbridge_agent.ini') }}"
    - sections:
        linux_bridge:
          physical_interface_mappings: public:eth0
        vxlan:
          enable_vxlan: True
          local_ip: {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','') }}
          l2_population: True
        agent:
          prevent_arp_spoofing: True
        securitygroup:
          enable_security_group: True
          firewall_driver: neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
    - require:
      - file: linuxbridge-agent-config-file

nova-compute-re-running:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:nova_compute', default='nova-compute') }}
    - watch: 
      - file: linuxbridge-agent-config-file
      - ini: nova-conf

neutron_plugin_linuxbridge_agent-running:
  service: 
    - running
    - name: "{{ salt['pillar.get']('services:neutron_plugin_linuxbridge_agent', default='neutron-plugin-linuxbridge-agent') }}"
    - watch: 
        - service: nova-compute-re-running
