# Vagrant-Linux-h2o-MariaDB-PHP7


VirtualMachine: Vagrant  
Supported OS: Ubuntu/Trusty or Debian/Jessie  
    (If you want to use Ubuntu/Xenial, maybe same settings Debian/Jessie. Not yet confirmed)  
front: h2o web server  
back: php7  
db: MariaDB


Usage:

1. Git clone this repository
    git clone https://github.com/mkgask/Vagrant-Linux-h2o-MariaDB-PHP7.git
    (If the git repository is not required, the zip or tar.gz file download & unzip)

2. Check and changing environment file
    itamae/roles/developing/environment.yml

3. Vagrant up

4. itamae ssh
    itamae ssh -h 192.168.33.22 -u vagrant --node-yaml=itamae/roles/developing/environment.yml itamae/roles/developing/server-setup.rb


If h2o and php-fpm is not connected, restart the service h2o and php-fpm.
