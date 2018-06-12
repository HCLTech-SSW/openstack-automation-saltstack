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
          bind-address: {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','') }}
          default-storage-engine: innodb
          innodb_file_per_table:
          collation-server: utf8_general_ci
          init-connect: 'SET NAMES utf8'
          character-set-server: utf8
    - require: 
        - file: mariadb-conf-file

install-mariadb: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:mariadb-server', default='mariadb-server') }}

mariadb-service-running:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:mysql', default='mysql') }}
    - watch: 
        - pkg: install-mariadb
        - ini: mariadb-conf-file
    - reload: True
