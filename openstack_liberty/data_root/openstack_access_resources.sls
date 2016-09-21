common_keys: 
  admin_token: "24811ee3d9a09915bef0"
  endpoint_host_sls: "controller.liberty"
  os_identity_version: "3"
  domain: "default"
  os_url: "http://{0}:35357/v3"
  os_username: "admin"
  os_password: "admin_pass"
  os_image_version: "2"

keystone:
  services: 
    keystone: 
      service_type: "identity"
      endpoint: 
        adminurl: "http://{0}:35357/v2.0"
        internalurl: "http://{0}:5000/v2.0"
        publicurl: "http://{0}:5000/v2.0"
        region: "RegionOne"
      description: "Openstack Identity"
      users: 
        admin: 
          password: "admin_pass"
          role: "admin"
        demo: 
          password: "demo_pass"
          role: "user"
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
      description: "Openstack Image Service"
      users: 
        glance: 
          password: "glance_pass"
          role: "admin"
nova:
  services:
    nova:
      service_type: "compute"
      endpoint:
        adminurl: "http://{0}:8774/v2/%\\(tenant_id\\)s"
        internalurl: "http://{0}:8774/v2/%\\(tenant_id\\)s"
        publicurl: "http://{0}:8774/v2/%\\(tenant_id\\)s"
        region: "RegionOne"
      description: "Openstack Compute Service"
      users: 
        nova:
          password: "nova_pass"
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
      description: "Openstack Block Storage Service"
      users: 
        cinder:
          password: "Cinder_pass"
          role: "admin"
