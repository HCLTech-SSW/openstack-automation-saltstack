{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

{% for user_name in pillar['neutron']['services']['neutron']['users'] %}
Identity_{{ user_name }}_creation:
  cmd: 
    - run
    - name: openstack user create --domain {{ pillar['common_keys']['domain'] }} --password {{ pillar['neutron']['services']['neutron']['users'][user_name]['password'] }} {{ user_name }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

Identity_{{ user_name }}_role_add:
  cmd: 
    - run
    - name: openstack role add --project service --user {{ user_name }} {{ pillar['neutron']['services']['neutron']['users'][user_name]['role'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

{% endfor %}
