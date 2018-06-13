{% from "openstack_initial/systemInfo/physical_networks.jinja" import mappings with context %}
{% from "openstack_initial/systemInfo/physical_networks.jinja" import vlan_networks with context %}
{% from "openstack_initial/systemInfo/physical_networks.jinja" import flat_networks with context %}
{% from "openstack_initial/systemInfo/system_resources.jinja" import ip4_interfaces with context %}

neutron_ml2:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:neutron_ml2', default='neutron-plugin-ml2') }}"

neutron_linuxbridge:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:neutron_linuxbridge_agent', default='neutron-linuxbridge-agent') }}"
    - require:
      - pkg: neutron_ml2

ml2_config_file:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:neutron_ml2', default='/etc/neutron/plugins/ml2/ml2_conf.ini') }}"
    - user: neutron
    - group: neutron
    - mode: 644
    - require:
      - pkg: neutron_ml2
      - pkg: neutron_linuxbridge
  ini:
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:neutron_ml2', default='/etc/neutron/plugins/ml2/ml2_conf.ini') }}"
    - sections:
        ml2:
          type_drivers: "{{ ','.join(pillar['neutron']['type_drivers']) }}"
          tenant_network_types: "vxlan"
          mechanism_drivers: linuxbridge,l2population
          extension_drivers: port_security
        ml2_type_flat:
          flat_networks: "provider"
        ml2_type_vxlan:
          vni_ranges: "{{ pillar['neutron']['type_drivers']['vxlan']['tunnel_start'] }}:{{ pillar['neutron']['type_drivers']['vxlan']['tunnel_end'] }}"
        securitygroup:
          enable_ipset: True
    - require:
      - file: ml2_config_file

linuxbridge_agent_config_file:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:neutron_linuxbridge_agent', default='/etc/neutron/plugins/ml2/linuxbridge_agent.ini') }}"
    - user: neutron
    - group: neutron
    - mode: 644
    - require:
      - file: ml2_config_file
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
      - file: linuxbridge_agent_config_file
