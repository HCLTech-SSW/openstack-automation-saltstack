{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}
{% from "openstack_initial/systemInfo/system_resources.jinja" import ip4_interfaces with context %}

nova-compute-install:
  pkg: 
    - installed
    - name: "{{ salt['pillar.get']('packages:nova_compute', default='nova-compute') }}"

nova-compute-dpkg-install:
  cmd: 
    - run
    - name: 'dpkg --configure -a'

nova-compute-running:
  service:
    - running
    - name: {{ salt['pillar.get']('services:nova_compute', default='nova-compute') }}
    - watch: 
      - file: nova-conf-compute

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
          transport_url: "rabbit://openstack:rabbit123@{{ pillar['controller_cluster'] }}"
{% for ipv4 in ip4_interfaces %}
          my_ip: "{{ ipv4 }}"
{% endfor %}
          firewall_driver: "nova.virt.firewall.NoopFirewallDriver"
          use_neutron: "True"
        api: 
          auth_strategy : "keystone"
        vnc: 
          enabled: "True"
          server_listen: "0.0.0.0"
          server_proxyclient_address: "$my_ip"
          novncproxy_base_url: "http://{{ pillar['controller_cluster'] }}:6080/vnc_auto.html"
        glance: 
          api_servers: "http://{{ pillar['controller_cluster'] }}:9292"
        oslo_concurrency: 
          lock_path: /var/lib/nova/tmp
        keystone_authtoken: 
          auth_url: "http://{{ pillar['controller_cluster'] }}:5000/v3"
          memcached_servers: "{{ pillar['controller_cluster'] }}:11211"
          auth_type: "password"
          project_domain_name: "default"
          user_domain_name: "default"
          project_name: "se rvice"
          username: "nova"
          password: "{{ pillar['nova']['services']['nova']['users']['nova']['password'] }}"
        placement: 
          os_region_name: "{{ pillar['common_keys']['bootstrap_regionid'] }}"
          project_domain_name: "default"
          project_name: "service"
          auth_type: "password"
          user_domain_name: "default"
          auth_url: "http://{{ pillar['controller_cluster'] }}:5000/v3"
          username: "placement"
          password: "{{ pillar['nova']['services']['placement']['users']['placement']['password'] }}"
        libvirt:
          virt_type: "qemu"
    - require: 
      - cmd: nova-compute-dpkg-install

