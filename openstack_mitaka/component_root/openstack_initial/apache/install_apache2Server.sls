{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

apache-install: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:apache', default='apache2') }}
    - require: 
      - pkg: memcached-install
      - service: memcached-service

apache-conf-file:
    file: 
      - append
      - name: {{ salt['pillar.get']('conf_files:apache2', default='/etc/apache2/apache2.conf') }}
      - text: ServerName {{ pillar['controller_cluster'] }}
      - require: 
          - pkg: apache-install

apache-service:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:apache', default='apache2') }}
    - watch: 
      - pkg: apache_wsgi_module
      - file: apache-conf-file

apache_wsgi_module: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:apache_wsgi_module', default='libapache2-mod-wsgi') }}
    - require: 
      - pkg: apache-install

memcached-install: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:memcached', default='memcached') }}

memcached-service:
  service: 
    - running
    - name: {{ salt['pillar.get']('services:memcached', default='memcached') }}
    - watch: 
      - file: memcached-conf

python-memcached:
  pkg.installed:
    - name: {{ salt['pillar.get']('packages:python_memcache', default='python-memcache') }}
    - require: 
      - pkg: apache-install

memcached-conf:
  file:
    - replace
    - name: "{{ salt['pillar.get']('conf_files:memcached', default='/etc/memcached.conf') }}"
    - backup: False
    - pattern: '127.0.0.1'
    - repl: {{ grains.ip4_interfaces.eth0|replace('[','')|replace(']','') }}
    - require: 
      - pkg: memcached-install
