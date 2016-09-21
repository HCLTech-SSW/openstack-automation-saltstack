{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

{% for user_name in pillar['neutron']['services']['neutron']['users'] %}
Identity_{{ user_name }}_creation:
  cmd: 
    - run
    - name: openstack user create --domain {{ pillar['common_keys']['domain'] }} --password {{ pillar['neutron']['services']['neutron']['users'][user_name]['password'] }} {{ user_name }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }}

Identity_{{ user_name }}_role_add:
  cmd: 
    - run
    - name: openstack role add --project service --user {{ user_name }} {{ pillar['neutron']['services']['neutron']['users'][user_name]['role'] }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

{% endfor %}
