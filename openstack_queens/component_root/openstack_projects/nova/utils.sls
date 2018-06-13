compute_service_show:
  cmd: 
    - run
    - name: openstack --os-username {{ pillar['common_keys']['os_username'] }} --os-project-name {{ pillar['common_keys']['os_username'] }} --os-user-domain-id {{ pillar['common_keys']['domain'] }} --os-project-domain-id {{ pillar['common_keys']['domain'] }} --os-identity-api-version {{ pillar['common_keys']['os_identity_version'] }} --os-auth-url {{ pillar['common_keys']['os_url'].format(pillar['controller_cluster']) }} --os-password {{ pillar['common_keys']['os_password'] }} compute service list --service nova-compute

{% if 'cell2_discover' in salt['pillar.get']('databases:nova_cell0', default=()) %}
discover_compute_hosts: 
  cmd: 
    - run
    - name: '/bin/sh -c "{{ salt['pillar.get']('databases:nova_cell0:cell2_discover') }}" nova'
    - require: 
        - cmd: compute_service_show
{% endif %}
