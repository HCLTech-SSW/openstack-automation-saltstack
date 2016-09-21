liberty: 
  "*.liberty": 
    - openstack_cluster_resources
    - openstack_access_resources
    - openstack_db_resources
    - openstack_cluster
    - openstack_machine_images
    - openstack_network_resources
    - {{ grains['os'] }}
    - {{ grains['os'] }}_repo

