{% from "openstack_initial/systemInfo/system_resources.jinja" import formulas with context %}
queens:
  "*.queens":
    - openstack_initial.preconfig.*
{% for formula in formulas %}
     - {{ formula }}
{% endfor %}
