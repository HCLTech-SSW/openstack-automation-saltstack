{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

Identity_image_list:
  cmd: 
    - run
    - name: glance --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-image-api-version {{ pillar['common_keys']['os_image_version'] }} image-list

Compute_service_list:
  cmd: 
    - run
    - name: nova --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} service-list

Networking_ext_list:
  cmd: 
    - run
    - name: neutron --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} ext-list

Networking_agent_list:
  cmd: 
    - run
    - name: neutron --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} agent-list

Cinder_service_list:
  cmd: 
    - run
    - name: cinder --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} service-list
