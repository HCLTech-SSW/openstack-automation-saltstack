common_keys: 
  admin_token: "24811ee3d9a09915bef0"
  endpoint_host_sls: "controller.mitaka"
  os_identity_version: "3"
  domain: "default"
  os_url: "http://{0}:35357/v3"
  os_username: "admin"
  os_password: "Admin_pass"
  os_image_version: "2"

keystone:
  services: 
    keystone: 
      service_type: "identity"
      endpoint: 
        adminurl: "http://{0}:35357/v3"
        internalurl: "http://{0}:5000/v3"
        publicurl: "http://{0}:5000/v3"
        region: "RegionOne"
      description: "Openstack Identity"
      users: 
        admin: 
          password: "Admin_pass"
          role: "admin"
        demo: 
          password: "Demo_pass"
          role: "user"
      domain:
        description: "Default Domain"
      projects:
        admin: 
          description: "Admin Project"
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
        adminurl: "http://{0}:8774/v2.1/%\\(tenant_id\\)s"
        internalurl: "http://{0}:8774/v2.1/%\\(tenant_id\\)s"
        publicurl: "http://{0}:8774/v2.1/%\\(tenant_id\\)s"
        region: "RegionOne"
      description: "Openstack Compute"
      users: 
        nova:
          password: "Nova_pass"
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
      service_type: "volume"
      service_type2: "volumev2"
      service_name2: "cinderv2"
      endpoint:
        adminurl: "http://{0}:8776/v1/%\\(tenant_id\\)s"
        internalurl: "http://{0}:8776/v1/%\\(tenant_id\\)s"
        publicurl: "http://{0}:8776/v1/%\\(tenant_id\\)s"
        adminurl2: "http://{0}:8776/v2/%\\(tenant_id\\)s"
        internalurl2: "http://{0}:8776/v2/%\\(tenant_id\\)s"
        publicurl2: "http://{0}:8776/v2/%\\(tenant_id\\)s"
        region: "RegionOne"
      description: "Openstack Block Storage"
      users: 
        cinder:
          password: "Cinder_pass"
          role: "admin"