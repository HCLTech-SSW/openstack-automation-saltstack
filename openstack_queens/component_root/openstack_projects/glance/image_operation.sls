{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

image_add:
  cmd:
    - run
    - name: wget {{ pillar['images']['copy_from'] }}

image_glance_create:
  cmd:
    - run
    - name: openstack --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }} image create {{ pillar['images']['name'] }} --file {{ pillar['images']['file'] }} --disk-format qcow2 --container-format bare --public
