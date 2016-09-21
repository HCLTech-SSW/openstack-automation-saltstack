install-mariadb-client: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:mariadb-client', default='mariadb-client') }}
python-mysql-library-install: 
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:python-mysql-library', default='python-pymysql') }}
    - require: 
        - pkg: install-mariadb-client
python-mysqldb-install:
  pkg: 
    - installed
    - name: {{ salt['pillar.get']('packages:python_mysqldb', default='python-mysqldb') }}
    - require: 
        - pkg: python-mysql-library-install
