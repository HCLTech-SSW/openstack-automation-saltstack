pkgrepo:
  pre_repo_additions:
    - "software-properties-common"
    - "ubuntu-cloud-keyring"
  repos:
    Liberty-Cloud:
      name: "deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/liberty main"
      file: "/etc/apt/sources.list.d/cloudarchive-liberty.list"
    MariaDB_Repo:
      name: "deb http://ftp.osuosl.org/pub/mariadb/repo/10.1/ubuntu trusty main"
      file: "/etc/apt/sources.list.d/cloudarchive-mariadb.list"
      keyserver: keyserver.ubuntu.com
      keyid: 1BB943DB
