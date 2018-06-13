neutron: 
  intergration_bridge: br-int
  metadata_secret: "414c66b22b1e7a20cc35"
  # uncomment to bridge all interfaces to primary interface
  # single_nic : primary_nic_name
  single_nic: "ens33"
  # make sure you add eth0 to br-proxy
  # and configure br-proxy with eth0's address
  # after highstate run
  type_drivers: 
    flat: 
      physnets: 
        External: 
          bridge: "br-ex"
          hosts:
            openstack.queens: "ens33"
    vlan: 
      physnets: 
        Internal1: 
          bridge: "br-eth1"
          vlan_range: "100:200"
          hosts:
            openstack.queens: "eth2"
    vxlan:
      tunnel_start: "1"
      tunnel_end: "1000"
  networks:
    Internal:
      subnets:
        InternalSubnet:
          cidr: '192.168.10.0/24'
    ExternalNetwork:
      provider_physical_network: External
      provider_network_type: flat
      shared: true
      router_external: true
      subnets:
        ExternalSubnet:
          cidr: '10.8.127.0/24'
          start_ip: '10.8.127.10'
          end_ip: '10.8.127.30'
          enable_dhcp: false
  routers:
    ExternalRouter:
      interfaces:
        - InternalSubnet
      external_gateway: ExternalNetwork
  security_groups:
    Default:
      description: 'Default security group'
      rules:
        - direction: ingress
          ethertype: ipv4
          remote_ip_prefix: '10.8.27.0/24'
        - direction: ingress
          remote_ip_prefix: '10.8.127.0/24'

