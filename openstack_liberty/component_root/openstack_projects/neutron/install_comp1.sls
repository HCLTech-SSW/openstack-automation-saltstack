{% from "openstack_initial/systemInfo/physical_networks.jinja" import mappings with context %}
{% from "openstack_initial/systemInfo/physical_networks.jinja" import vlan_networks with context %}
{% from "openstack_initial/systemInfo/physical_networks.jinja" import flat_networks with context %}

neutron_ml2:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:neutron_ml2', default='neutron-plugin-ml2') }}"

neutron_linuxbridge:
  pkg:
    - installed
    - name: "{{ salt['pillar.get']('packages:neutron_plugin_linuxbridge_agent', default='neutron-plugin-linuxbridge-agent') }}"
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
          flat_networks: "public"
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
          physical_interface_mappings: "public:eth0"
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
      - file: linuxbridge_agent_config_file
