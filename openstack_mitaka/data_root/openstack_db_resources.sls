databases: 
  keystone:  
    db_name: "keystone"
    username: "keystone"
    password: "keystone_pass"
    service: "keystone"
    db_sync: "keystone-manage db_sync"
  glance: 
    db_name: "glance"
    username: "glance"
    password: "glance_pass"
    service: "glance"
    db_sync: "glance-manage db_sync"
  nova:
    db_name: "nova"
    username: "nova"
    password: "nova_pass"
    service: "nova-api"
    db_sync: "nova-manage db sync"
  nova_api: 
    db_name: "nova_api"
    username: "nova"
    password: "nova_pass"
    service: "nova-api"
    db_sync: "nova-manage api_db sync"
  neutron: 
    db_name: "neutron"
    username: "neutron"
    password: "neutron_pass"
    db_sync: "neutron-db-manage"
  cinder: 
    db_name: "cinder"
    username: "cinder"
    password: "cinder_pass"
    service: "cinder"
    db_sync: "cinder-manage db sync"
