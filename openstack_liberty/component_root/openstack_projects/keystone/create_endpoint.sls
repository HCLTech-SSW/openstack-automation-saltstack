{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

{% for service_name in pillar['keystone']['services'] %}
Identity_{{ service_name }}_publicurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['keystone']['services'][service_name]['endpoint']['region'] }} {{ pillar['keystone']['services'][service_name]['service_type'] }} public {{ pillar['keystone']['services'][service_name]['endpoint']['publicurl'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Identity_{{ service_name }}_internalurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['keystone']['services'][service_name]['endpoint']['region'] }} {{ pillar['keystone']['services'][service_name]['service_type'] }} internal {{ pillar['keystone']['services'][service_name]['endpoint']['internalurl'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Identity_{{ service_name }}_adminurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['keystone']['services'][service_name]['endpoint']['region'] }} {{ pillar['keystone']['services'][service_name]['service_type'] }} admin {{ pillar['keystone']['services'][service_name]['endpoint']['adminurl'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

{% endfor %}
