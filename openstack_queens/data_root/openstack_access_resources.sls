common_keys: 
  endpoint_host_sls: "controller.queens"
  os_identity_version: "3"
  domain: "default"
  os_url: "http://{0}:5000"
  os_username: "admin"
  os_password: "Admin_pass"
  os_image_version: "2"
  etcd_user: "etcd"
  bootstrap_adminurl: "http://{0}:5000/v3/"
  bootstrap_internalurl: "http://{0}:5000/v3/"
  bootstrap_publicurl: "http://{0}:5000/v3/"
  bootstrap_regionid: "RegionOne"  

keystone:
  services: 
    keystone: 
      users: 
        demo: 
          password: "Demo_pass"
          role: "user"
      projects:
        demo: 
          description: "Demo Project"
        service: 
          description: "Service Project"
glance:
  services: 
    glance: 
      service_type: "image"
      endpoint: 
        adminurl: "http://{0}:9292"
        internalurl: "http://{0}:9292"
        publicurl: "http://{0}:9292"
        region: "RegionOne"
      description: "Openstack Image"
      users: 
        glance: 
          password: "Glance_pass"
          role: "admin"
nova:
  services:
    nova:
      service_type: "compute"
      endpoint:
        adminurl: "http://{0}:8774/v2.1"
        internalurl: "http://{0}:8774/v2.1"
        publicurl: "http://{0}:8774/v2.1"
        region: "RegionOne"
      description: "Openstack Compute"
      users: 
        nova:
          password: "Nova_pass"
          role: "admin"
    placement:
      service_type: "placement"
      endpoint:
        adminurl: "http://{0}:8778"
        internalurl: "http://{0}:8778"
        publicurl: "http://{0}:8778"
        region: "RegionOne"
      description: "Placement API"
      users: 
        placement:
          password: "Placement_pass"
          role: "admin"

neutron:
  services:
    neutron:
      service_type: "network"
      endpoint:
        adminurl: "http://{0}:9696"
        internalurl: "http://{0}:9696"
        publicurl: "http://{0}:9696"
        region: "RegionOne"
      description: "Openstack Networking"
      users: 
        neutron:
          password: "Neutron_pass"
          role: "admin"
cinder:
  services:
    cinder:
      service_type1: "volumev2"
      service_name1: "cinderv2"
      service_type2: "volumev3"
      service_name2: "cinderv3"
      endpoint:
        adminurl: "http://{0}:8776/v2/%\\(project_id\\)s"
        internalurl: "http://{0}:8776/v2/%\\(project_id\\)s"
        publicurl: "http://{0}:8776/v2/%\\(project_id\\)s"
        adminurl2: "http://{0}:8776/v3/%\\(project_id\\)s"
        internalurl2: "http://{0}:8776/v3/%\\(project_id\\)s"
        publicurl2: "http://{0}:8776/v3/%\\(project_id\\)s"
        region: "RegionOne"
      description: "Openstack Block Storage"
      users: 
        cinder:
          password: "Cinder_pass"
          role: "admin"
