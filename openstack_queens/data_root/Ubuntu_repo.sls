pkgrepo:
  pre_repo_additions:
    - "software-properties-common"
    - "ubuntu-cloud-keyring"
  repos:
    queens-Cloud:
      name: "deb http://ubuntu-cloud.archive.canonical.com/ubuntu xenial-updates/queens main"
      file: "/etc/apt/sources.list.d/cloudarchive-queens.list"
    MariaDB_Repo:
      name: "deb http://download.nus.edu.sg/mirror/mariadb/repo/10.1/ubuntu xenial main"
      file: "/etc/apt/sources.list.d/cloudarchive-mariadb.list"
      keyserver: keyserver.ubuntu.com
      keyid: "C74CD1D8"
