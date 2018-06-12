update_network_interface_{{ grains['id'] }}:
  file:
    - append
    - name: /etc/network/interfaces
    - text: 
        - auto eth0
        - iface  eth0 inet manual
        - up ip link set dev $IFACE up
        - down ip link set dev $IFACE down

update_network_manager_conf_{{ grains['id'] }}:
  file: 
    - managed
    - name: "{{ salt['pillar.get']('conf_files:network_manager_conf', default='/etc/NetworkManager/NetworkManager.conf') }}"
    - mode: 644
    - require: 
      - file: update_network_interface_{{ grains['id'] }}
  ini: 
    - options_present
    - name: "{{ salt['pillar.get']('conf_files:network_manager_conf', default='/etc/NetworkManager/NetworkManager.conf') }}"
    - sections: 
        ifupdown:
          managed: "true"
    - require: 
      - file: update_network_manager_conf_{{ grains['id'] }}

network_manager_service_{{ grains['id'] }}:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:network_manager', default='network-manager') }}
    - watch: 
      - file: update_network_manager_conf_{{ grains['id'] }}
