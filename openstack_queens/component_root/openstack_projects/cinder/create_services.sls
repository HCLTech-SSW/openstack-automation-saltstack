{% from "openstack_initial/systemInfo/system_resources.jinja" import get_candidate with context %}
{% for service_name in pillar['cinder']['services'] %}
Identity_{{ service_name }}_v2_service:
  cmd: 
    - run
    - name: openstack service create --name {{ pillar['cinder']['services'][service_name]['service_name1'] }} --description "{{ pillar['cinder']['services'][service_name]['description'] }}" {{ pillar['cinder']['services'][service_name]['service_type1'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

Identity_{{ service_name }}_v3_service:
  cmd: 
    - run
    - name: openstack service create --name {{ pillar['cinder']['services'][service_name]['service_name2'] }} --description "{{ pillar['cinder']['services'][service_name]['description'] }}" {{ pillar['cinder']['services'][service_name]['service_type2'] }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

Image_{{ service_name }}_v2_publicurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type1'] }} public {{ pillar['cinder']['services'][service_name]['endpoint']['publicurl'].format(pillar['controller_cluster']) }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

Image_{{ service_name }}_v3_publicurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type2'] }} public {{ pillar['cinder']['services'][service_name]['endpoint']['publicurl2'].format(pillar['controller_cluster']) }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

Image_{{ service_name }}_v2_internalurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type1'] }} internal {{ pillar['cinder']['services'][service_name]['endpoint']['internalurl'].format(pillar['controller_cluster']) }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

Image_{{ service_name }}_v3_internalurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type2'] }} internal {{ pillar['cinder']['services'][service_name]['endpoint']['internalurl2'].format(pillar['controller_cluster']) }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

Image_{{ service_name }}_v2_adminurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type1'] }} admin {{ pillar['cinder']['services'][service_name]['endpoint']['adminurl'].format(pillar['controller_cluster']) }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

Image_{{ service_name }}_v3_adminurl:
  cmd: 
    - run
    - name: openstack endpoint create --region {{ pillar['cinder']['services'][service_name]['endpoint']['region'] }} {{ pillar['cinder']['services'][service_name]['service_type2'] }} admin {{ pillar['cinder']['services'][service_name]['endpoint']['adminurl2'].format(pillar['controller_cluster']) }} --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }}

{% endfor %}
