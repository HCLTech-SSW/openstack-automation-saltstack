{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}
{% from "openstack_initial/systemInfo/physical_networks.jinja" import bridges with context %}
{% from "openstack_initial/systemInfo/physical_networks.jinja" import flat_networks with context %}
{% from "openstack_initial/systemInfo/system_resources.jinja" import ip4_interfaces with context %}

neutron-linuxbridge-agent-install:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:neutron_linuxbridge_agent', default='neutron-linuxbridge-agent') }}"

neutron-pre-compute-conf-file:
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:neutron', default='/etc/neutron/neutron.conf') }}"
    - user: neutron
    - group: neutron
    - mode: 644
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
          transport_url: "rabbit://openstack:rabbit123@{{ pillar['controller_cluster'] }}"
          auth_strategy: keystone
        keystone_authtoken: 
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:5000"
          memcached_servers: "{{ pillar['controller_cluster'] }}:11211"
          auth_type: "password"
          project_domain_name: "default"
          user_domain_name: "default"
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
          auth_url: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_type: "password"
          project_domain_name: "default"
          user_domain_name: "default"
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
          physical_interface_mappings: "provider:{{ pillar['neutron']['single_nic'] }}"
        vxlan:
          enable_vxlan: true
{% for ipv4 in ip4_interfaces %}
          local_ip: "{{ ipv4 }}"
{% endfor %}
          l2_population: true
        securitygroup:
          enable_security_group: true
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

neutron_linuxbridge_agent-running:
  service: 
    - running
    - name: "{{ salt['pillar.get']('services:neutron_linuxbridge_agent', default='neutron-linuxbridge-agent') }}"
    - watch: 
        - service: nova-compute-re-running
