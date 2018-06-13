{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}

{% for service_name in pillar['nova']['services'] %}
Compute_{{ service_name }}_service:
  cmd: 
    - run
    - name: openstack service create --name {{ service_name }} --description "{{ pillar['nova']['services'][service_name]['description'] }}" {{ pillar['nova']['services'][service_name]['service_type'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

Compute_{{ service_name }}_publicurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['nova']['services'][service_name]['endpoint']['region'] }} {{ pillar['nova']['services'][service_name]['service_type'] }} public {{ pillar['nova']['services'][service_name]['endpoint']['publicurl'].format(pillar['controller_cluster']) }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

Compute_{{ service_name }}_internalurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['nova']['services'][service_name]['endpoint']['region'] }} {{ pillar['nova']['services'][service_name]['service_type'] }} internal {{ pillar['nova']['services'][service_name]['endpoint']['internalurl'].format(pillar['controller_cluster']) }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

Compute_{{ service_name }}_adminurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['nova']['services'][service_name]['endpoint']['region'] }} {{ pillar['nova']['services'][service_name]['service_type'] }} admin {{ pillar['nova']['services'][service_name]['endpoint']['adminurl'].format(pillar['controller_cluster']) }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

{% endfor %}
