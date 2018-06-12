{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

neutron-dhcp-agent-install: 
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:neutron_dhcp_agent', default='neutron-dhcp-agent') }}"

neutron-dhcp-agent-running:
  service: 
    - running
    - name: "{{ salt['pillar.get']('services:neutron_dhcp_agent', default='neutron-dhcp-agent') }}"
    - watch: 
      - service: neutron_plugin_linuxbridge_agent-running

neutron-dhcp-agent-config:
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:neutron_dhcp_agent', default='/etc/neutron/dhcp_agent.ini') }}"
    - user: neutron
    - group: neutron
    - mode: 644
    - require: 
      - pkg: neutron-dhcp-agent-install
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:neutron_dhcp_agent', default='/etc/neutron/dhcp_agent.ini') }}"
    - sections: 
        DEFAULT: 
          interface_driver: neutron.agent.linux.interface.BridgeInterfaceDriver
          dhcp_driver: neutron.agent.linux.dhcp.Dnsmasq
          enable_isolated_metadata: True
          dnsmasq_config_file: "/etc/neutron/dnsmasq-neutron.conf"

dnsmasq-conf:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:dns_masq', default='/etc/neutron/dnsmasq-neutron.conf') }}"
    - create: true
    - contents:
        - dhcp-options-force=26,1450
    - require:
        - file: neutron-dhcp-agent-config

neutron-metadata-agent-install: 
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:neutron_metadata_agent', default='neutron-metadata-agent') }}"

python-neutron-client-install: 
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:python_neutronclient', default='python-neutronclient') }}"
    - require: 
      - pkg: neutron-metadata-agent-install

conntrack-install: 
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:conntrack', default='conntrack') }}"
    - require: 
      - pkg: python-neutron-client-install

neutron-metadata-agent-running:
  service: 
    - running
    - name: "{{ salt['pillar.get']('services:neutron_metadata_agent', default='neutron-metadata-agent') }}"
    - watch: 
      - service: neutron-dhcp-agent-running

neutron-metadata-agent-conf:
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:neutron_metadata_agent', default='/etc/neutron/metadata_agent.ini') }}"
    - user: neutron
    - group: neutron
    - mode: 644
    - require: 
      - ini: neutron-metadata-agent-conf
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:neutron_metadata_agent', default='/etc/neutron/metadata_agent.ini') }}"
    - sections: 
        DEFAULT: 
          auth_uri: "http://{{ pillar['controller_cluster'] }}:5000"
          auth_url: "http://{{ pillar['controller_cluster'] }}:35357"
          auth_region: "RedionOne"
          auth_plugin: "password"
          project_domain_id: "default"
          user_domain_id: "default"
          project_name: "service"
          username: neutron
          password: "{{ pillar['neutron']['services']['neutron']['users']['neutron']['password'] }}"
          nova_metadata_ip: "{{ pillar['controller_cluster'] }}"
          metadata_proxy_shared_secret: "{{ pillar['neutron']['metadata_secret'] }}"
    - require: 
      - pkg: neutron-metadata-agent-install
      - file: neutron-l3-agent-config

nova-neutron-conf:
  file:
    - managed
    - name: "{{ salt['pillar.get']('conf_files:nova', default='/etc/nova/nova.conf') }}"
    - user: nova
    - group: nova
    - mode: 644
    - require:
      - file: neutron-metadata-agent-conf
      - ini: nova-neutron-conf
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
          service_metadata_proxy: True
          metadata_proxy_shared_secret: "{{ pillar['neutron']['metadata_secret'] }}"

neutron-l3-agent-install: 
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:neutron_l3_agent', default='neutron-l3-agent') }}"

neutron-l3-agent-running:
  service: 
    - running
    - name: "{{ salt['pillar.get']('services:neutron_l3_agent', default='neutron-l3-agent') }}"
    - watch: 
      - service: neutron-metadata-agent-running

neutron-l3-agent-config:
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:neutron_l3_agent', default='/etc/neutron/l3_agent.ini') }}"
    - user: neutron
    - group: neutron
    - mode: 644
    - require: 
      - ini: neutron-l3-agent-config
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:neutron_l3_agent', default='/etc/neutron/l3_agent.ini') }}"
    - sections: 
        DEFAULT: 
          interface_driver: neutron.agent.linux.interface.BridgeInterfaceDriver
          external_network_bridge:
    - require: 
      - pkg: neutron-l3-agent-install
      - file: neutron-dhcp-agent-config

neutron_sync: 
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:neutron:db_sync') }} --config-file {{ salt['pillar.get']('conf_files:neutron', default='/etc/neutron/neutron.conf') }} --config-file {{ salt['pillar.get']('conf_files:neutron_ml2', default='/etc/neutron/plugins/ml2/ml2_conf.ini') }} upgrade head" neutron'
    - require: 
        - file: nova-neutron-conf

nova-api-service-running:
  service:
    - running
    - name: "{{ salt['pillar.get']('services:nova_api', default='nova-api') }}"
    - watch:
      - cmd: neutron_sync

neutron-server-service:
  service: 
    - running
    - name: "{{ salt['pillar.get']('services:neutron_server', default='neutron-server') }}"
    - watch: 
        - service: nova-api-service-running

neutron_plugin_linuxbridge_agent-running:
  service: 
    - running
    - name: "{{ salt['pillar.get']('services:neutron_plugin_linuxbridge_agent', default='neutron-plugin-linuxbridge-agent') }}"
    - watch: 
        - service: neutron-server-service

neutron_sqlite_delete:
  file:
    - absent
    - name: /var/lib/neutron/neutron.sqlite
    - require:
        - service: neutron-l3-agent-running
