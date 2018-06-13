{% from "openstack_initial/systemInfo/system_resources.jinja" import ip4_interfaces with context %}

etcd_user_create:
  cmd: 
    - run
    - name: groupadd --system {{ pillar['common_keys']['etcd_user'] }} && useradd --home-dir "/var/lib/etcd" --system --shell /bin/false -g {{ pillar['common_keys']['etcd_user'] }} {{ pillar['common_keys']['etcd_user'] }}
  
etcd_user_dir_create:
  cmd: 
    - run
    - name: mkdir -p /etc/etcd && chown etcd:etcd /etc/etcd && mkdir -p /var/lib/etcd && chown etcd:etcd /var/lib/etcd
    - require: 
      - cmd: etcd_user_create
  
download_install_etcd:
  cmd: 
    - run
    - name: ETCD_VER=v3.2.7 && rm -rf /tmp/etcd && curl -L https://github.com/coreos/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
    - require: 
      - cmd: etcd_user_dir_create

unzip_downloaded_etcd_tar:
  cmd: 
    - run
    - name: mkdir /tmp/etcd && tar xzvf /tmp/etcd-v3.2.7-linux-amd64.tar.gz -C /tmp/etcd --strip-components=1
    - require: 
      - cmd: download_install_etcd

copy_etcd_tmp_files:
  cmd: 
    - run
    - name: cp /tmp/etcd/etcd /usr/bin/etcd && cp /tmp/etcd/etcdctl /usr/bin/etcdctl
    - require: 
      - cmd: unzip_downloaded_etcd_tar

etcd_conf_file:     
  file.managed:
    - name: {{ salt['pillar.get']('conf_files:etcd_conf', default='/etc/etcd/etcd.conf.yml') }}
    - create: true
    - contents:
      - "name: controller"
      - "data-dir: /var/lib/etcd"
      - "initial-cluster-state: 'new'"
      - "initial-cluster-token: 'etcd-cluster-01'"
{% for ipv4 in ip4_interfaces %}
      - 'initial-cluster: controller=http://{{ ipv4 }}:2380'
      - 'initial-advertise-peer-urls: http://{{ ipv4 }}:2380'
      - 'advertise-client-urls: http://{{ ipv4 }}:2379'
      - 'listen-peer-urls: http://0.0.0.0:2380'
      - 'listen-client-urls: http://{{ ipv4 }}:2379'
{% endfor %}
    - require:
      -  cmd: copy_etcd_tmp_files
  
etcd_service_conf_file:     
    file: 
      - managed
      - name: {{ salt['pillar.get']('conf_files:etcd_service_conf', default='/lib/systemd/system/etcd.service') }}
      - user: root
      - group: root
      - mode: 644
      - require: 
          - file: etcd_conf_file
    ini: 
      - options_present
      - name: {{ salt['pillar.get']('conf_files:etcd_service_conf', default='/lib/systemd/system/etcd.service') }}
      - sections: 
          Unit: 
            After: "network.target"
            Description: "etcd - highly-available key value store"
          Service: 
            LimitNOFILE: "65536"
            Restart: "on-failure"
            Type: "notify"
            ExecStart: "/usr/bin/etcd --config-file /etc/etcd/etcd.conf.yml"
            User: "{{ pillar['common_keys']['etcd_user'] }}"
          Install: 
            WantedBy: "multi-user.target"
      - require: 
          - file: etcd_service_conf_file

etcd_service_running:
  cmd: 
    - run
    - name: systemctl enable etcd && systemctl start etcd
    - require: 
      - file: etcd_service_conf_file
