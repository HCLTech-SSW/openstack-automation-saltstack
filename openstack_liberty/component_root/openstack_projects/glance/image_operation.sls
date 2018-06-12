{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

image-add:
  cmd:
    - run
    - name: wget {{ pillar['images']['copy_from'] }}

image-glance-create:
  cmd:
    - run
    - name: glance --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-tenant-name {{ pillar['common_keys']['os_username'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-image-api-version {{ pillar['common_keys']['os_image_version'] }} image-create --name {{ pillar['images']['name'] }} --file {{ pillar['images']['file'] }} --disk-format qcow2 --container-format bare --visibility public --progress

