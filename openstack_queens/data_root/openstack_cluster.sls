#queue backend 
queue_engine: rabbit

#db_backend
db_engine: mysql

#Uncomment below line if there is a valid package proxy
#pkg_proxy_url: "http://mars:3142"
#Data to identify cluster
cluster_type: queens

#Name of Openstack controller cluster
#The grains id of openstack controller cluster be added on the below variable.        
controller_cluster: "controller.queens"

#Name of the Physical volume drive for blockstorage.
blockstorage_drive: "/dev/sdb"

#Name of the volume group created for blockstorage.
vg_name: "cinder-volumes"

#Hosts and their ip addresses
#The order below should be followed by adding openstack controller cluster, compute cluster and then 
#other remaining clusters. Add the grains id here (i.e. name of minion registered as grains on minion by using 
#the command echo 'controller.queens' > /etc/salt/minion_id)
#The grains id of openstack controller cluster should also be added on the variable "" in access_resources.sls.        
hosts: 
  controller.queens: 192.168.200.139
  compute.queens: 192.168.200.138
  blockstorage.queens: 192.168.200.141