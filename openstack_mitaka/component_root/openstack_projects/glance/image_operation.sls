{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

image-add:
  cmd:
    - run
    - name: wget {{ pillar['images']['copy_from'] }}

image-glance-create:
  cmd:
    - run
    - name: openstack --os-username {{ pillar['common_keys']['os_username'] }} --os-password {{ pillar['common_keys']['os_password'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-domain-name {{ pillar['common_keys']['domain'] }} image create {{ pillar['images']['name'] }} --file {{ pillar['images']['file'] }} --disk-format qcow2 --container-format bare --public
