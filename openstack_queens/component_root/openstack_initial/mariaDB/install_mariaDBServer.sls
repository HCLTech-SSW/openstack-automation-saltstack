{% from "openstack_initial/systemInfo/system_resources.jinja" import ip4_interfaces with context %}

install-mariadb: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:mariadb-server', default='mariadb-server') }}

mariadb-conf-file:
  file: 
    - managed
    - group: root
      mode: 644
      name: {{ salt['pillar.get']('conf_files:mariadb', default='/etc/mysql/my.cnf') }}
      user: root
      require: 
        - pkg: mariadb-server
  ini: 
    - options_present
    - name: {{ salt['pillar.get']('conf_files:mariadb', default='/etc/mysql/my.cnf') }}
    - sections: 
        mysqld:
{% for ipv4 in ip4_interfaces %}
          bind-address: "{{ ipv4 }}"
{% endfor %}
          default-storage-engine: innodb
          innodb_file_per_table: on
          max_connections: 4096
          collation-server: utf8_general_ci
          character-set-server: utf8
    - require: 
        - file: mariadb-conf-file

mariadb-service-running:
  service: 
    - running
    - enable: True
    - name: {{ salt['pillar.get']('services:mysql', default='mysql') }}
    - reload: False
    - watch: 
        - pkg: install-mariadb
        - ini: mariadb-conf-file

