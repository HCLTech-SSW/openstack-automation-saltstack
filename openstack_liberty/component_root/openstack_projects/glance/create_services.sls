{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

{% for service_name in pillar['glance']['services'] %}
Identity_{{ service_name }}_service:
  cmd: 
    - run
    - name: openstack service create --name {{ service_name }} --description "{{ pillar['glance']['services'][service_name]['description'] }}" {{ pillar['glance']['services'][service_name]['service_type'] }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Image_{{ service_name }}_publicurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['glance']['services'][service_name]['endpoint']['region'] }} {{ pillar['glance']['services'][service_name]['service_type'] }} public {{ pillar['glance']['services'][service_name]['endpoint']['publicurl'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Image_{{ service_name }}_internalurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['glance']['services'][service_name]['endpoint']['region'] }} {{ pillar['glance']['services'][service_name]['service_type'] }} internal {{ pillar['glance']['services'][service_name]['endpoint']['internalurl'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Image_{{ service_name }}_adminurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['glance']['services'][service_name]['endpoint']['region'] }} {{ pillar['glance']['services'][service_name]['service_type'] }} admin {{ pillar['glance']['services'][service_name]['endpoint']['adminurl'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

{% endfor %}
