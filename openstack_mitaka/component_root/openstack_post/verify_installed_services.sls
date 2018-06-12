Identity_image_list:
  cmd: 
    - run
    - name: openstack --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-domain-name {{ pillar['common_keys']['domain'] }} image list

Compute_service_list:
  cmd: 
    - run
    - name: openstack --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-domain-name {{ pillar['common_keys']['domain'] }} compute service list

Networking_ext_list:
  cmd: 
    - run
    - name: neutron --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-project-domain-name {{ pillar['common_keys']['domain'] }} --os-user-domain-name {{ pillar['common_keys']['domain'] }} --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} ext-list

Networking_agent_list:
  cmd: 
    - run
    - name: neutron --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-project-domain-name {{ pillar['common_keys']['domain'] }} --os-user-domain-name {{ pillar['common_keys']['domain'] }} --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} agent-list

Cinder_service_list:
  cmd: 
    - run
    - name: cinder --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-project-domain-name {{ pillar['common_keys']['domain'] }} --os-user-domain-name {{ pillar['common_keys']['domain'] }} --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} service-list


