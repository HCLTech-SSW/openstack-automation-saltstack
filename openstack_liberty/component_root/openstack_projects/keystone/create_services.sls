{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

{% for service_name in pillar['keystone']['services'] %}
Identity_{{ service_name }}_service:
  cmd: 
    - run
    - name: openstack service create --name {{ service_name }} --description "{{ pillar['keystone']['services'][service_name]['description'] }}" {{ pillar['keystone']['services'][service_name]['service_type'] }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}
{% endfor %}
