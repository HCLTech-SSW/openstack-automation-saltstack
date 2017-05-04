packages:
  linux-headers: linux-headers-{{ grains['kernelrelease'] }}
  mariadb-client: mariadb-client
  python-mysql-library: python-pymysql
  mariadb-server: mariadb-server
  rabbitmq: rabbitmq-server
  keystone: keystone
  glance: glance
  cinder_api: cinder-api
  cinder_scheduler: cinder-scheduler
  cinder_volume: cinder-volume
  lvm: lvm2
  apache: apache2
  apache_wsgi_module: libapache2-mod-wsgi
  memcached: memcached
  dashboard: openstack-dashboard
  nova_api: nova-api
  nova_conductor: nova-conductor
  nova_scheduler: nova-scheduler
  nova_consoleauth: nova-consoleauth
  nova_novncproxy: nova-novncproxy
  nova_compute: nova-compute
  python_memcache: python-memcache
  python_mysqldb: python-mysqldb
  python_openstackclient: python-openstackclient
  neutron_server: neutron-server
  neutron_ml2: neutron-plugin-ml2
  neutron_linuxbridge_agent: neutron-linuxbridge-agent
  neutron_l3_agent: neutron-l3-agent
  neutron_dhcp_agent: neutron-dhcp-agent
  neutron_metadata_agent: neutron-metadata-agent

services:
  mysql: mysql
  rabbitmq: rabbitmq-server
  keystone: keystone
  glance_api: glance-api
  glance_registry: glance-registry
  cinder_api: cinder-api
  cinder_scheduler: cinder-scheduler
  cinder_volume: cinder-volume
  iscsi_target: tgt
  apache: apache2
  memcached: memcached
  neutron_server: neutron-server
  neutron_linuxbridge_agent: neutron-linuxbridge-agent
  neutron_dhcp_agent: neutron-dhcp-agent
  neutron_l3_agent: neutron-l3-agent
  neutron_metadata_agent: neutron-metadata-agent
  nova_api: nova-api
  nova_conductor: nova-conductor
  nova_scheduler: nova-scheduler
  nova_cert: nova-cert
  nova_consoleauth: nova-consoleauth
  nova_novncproxy: nova-novncproxy
  nova_compute: nova-compute
  network_manager: network-manager
  tgt: tgt

conf_files:
  mariadb: "/etc/mysql/my.cnf"
  rabbitmq: "/etc/rabbitmq/rabbitmq-env.conf"
  memcached: "/etc/memcached.conf"
  keystone: "/etc/keystone/keystone.conf"
  apache2: "/etc/apache2/apache2.conf"
  glance_api: "/etc/glance/glance-api.conf"
  glance_registry: "/etc/glance/glance-registry.conf"
  cinder: "/etc/cinder/cinder.conf"
  neutron: "/etc/neutron/neutron.conf"
  neutron_ml2: "/etc/neutron/plugins/ml2/ml2_conf.ini"
  neutron_linuxbridge_agent: "/etc/neutron/plugins/ml2/linuxbridge_agent.ini"
  neutron_dhcp_agent: "/etc/neutron/dhcp_agent.ini"
  neutron_l3_agent: "/etc/neutron/l3_agent.ini"
  neutron_metadata_agent: "/etc/neutron/metadata_agent.ini"
  syslinux: "/etc/sysctl.conf"
  nova: "/etc/nova/nova.conf"
  nova_compute: "/etc/nova/nova-compute.conf"
  network_manager_conf: "/etc/NetworkManager/NetworkManager.conf"
  openstack_dashboard_conf: "/etc/openstack-dashboard/local_settings.py"
  lvm: "/etc/lvm/lvm.conf"
  openstack_conf: "/etc/apache2/conf-available/openstack-dashboard.conf"
