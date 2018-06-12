{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}
{% for service_name in pillar['cinder']['services'] %}
Identity_{{ service_name }}_service:
  cmd: 
    - run
    - name: openstack service create --name {{ service_name }} --description "{{ pillar['cinder']['services'][service_name]['description'] }}" {{ pillar['cinder']['services'][service_name]['service_type'] }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Identity_{{ service_name }}_v2_service:
  cmd: 
    - run
    - name: openstack service create --name {{ pillar['cinder']['services'][service_name]['service_name2'] }} --description "{{ pillar['cinder']['services'][service_name]['description'] }}" {{ pillar['cinder']['services'][service_name]['service_type2'] }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Image_{{ service_name }}_publicurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type'] }} public {{ pillar['cinder']['services'][service_name]['endpoint']['publicurl'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Image_{{ service_name }}_v2_publicurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type2'] }} public {{ pillar['cinder']['services'][service_name]['endpoint']['publicurl2'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Image_{{ service_name }}_internalurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type'] }} internal {{ pillar['cinder']['services'][service_name]['endpoint']['internalurl'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Image_{{ service_name }}_v2_internalurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type2'] }} internal {{ pillar['cinder']['services'][service_name]['endpoint']['internalurl2'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Image_{{ service_name }}_adminurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type'] }} admin {{ pillar['cinder']['services'][service_name]['endpoint']['adminurl'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

Image_{{ service_name }}_v2_adminurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type2'] }} admin {{ pillar['cinder']['services'][service_name]['endpoint']['adminurl2'].format(pillar['controller_cluster']) }} --os-token {{ pillar['common_keys']['admin_token'] }} --os-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }}

{% endfor %}
