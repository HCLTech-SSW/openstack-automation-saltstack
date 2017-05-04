pkgrepo:
  pre_repo_additions:
    - "software-properties-common"
    - "ubuntu-cloud-keyring"
  repos:
    mitaka-Cloud:
      name: "deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/mitaka main"
      file: "/etc/apt/sources.list.d/cloudarchive-mitaka.list"
    MariaDB_Repo:
      name: "deb http://ftp.osuosl.org/pub/mariadb/repo/10.1/ubuntu trusty main"
      file: "/etc/apt/sources.list.d/cloudarchive-mariadb.list"
      keyserver: keyserver.ubuntu.com
      keyid: 1BB943DB
