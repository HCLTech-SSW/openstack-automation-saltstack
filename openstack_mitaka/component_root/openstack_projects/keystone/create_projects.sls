{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

Identity_domain_create:
  cmd: 
    - run
    - name: openstack domain create --description "{{ pillar['keystone']['services']['keystone']['domain']['description'] }}" {{ pillar['common_keys']['domain'] }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

{% for project_name  in pillar['keystone']['services']['keystone']['projects'] %}
Identity_{{ project_name }}:
  cmd: 
    - run
    - name: openstack project create --domain {{ pillar['common_keys']['domain'] }} --description "{{ pillar['keystone']['services']['keystone']['projects'][project_name]['description'] }}" {{ project_name }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}
{% endfor %}
