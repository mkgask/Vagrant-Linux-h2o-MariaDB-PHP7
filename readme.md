# Vagrant-Linux-h2o-mysqlenv-phpenv

| type | value |
|------|-------|
| VirtualMachine | Vagrant |
| Supported OS | Ubuntu/Xenial64 (16.04) or Ubuntu/Trusty64 (14.04) or Debian/Jessie |
| front | h2o web server (default:2.2.0) |
| app   | [phpenv](https://github.com/madumlao/phpenv) (default:php7.1.3) |
| db    | [mysqlenv](https://github.com/shim0mura/mysqlenv) (default:mariadb-10.2.5) |


Usage:

1. Git clone this repository  
    ```
    git clone https://github.com/mkgask/vlhmp
    ```  
    (If the git repository is not required, the zip or tar.gz file download & unzip)

2. Check and changing environment yml file  
    itamae/roles/dev/env.yml

3. Vagrant up  
    ```
    vagrant up
    ```

4. Execute Itamae ssh  
    ```
    itamae ssh --vagrant -h 192.168.33.71 -u ubuntu -y=itamae/roles/dev/env.yml itamae/roles/dev/setup.rb
    ```

5. Get a coffee and snack break time, because take a long time execute.

If h2o and php-fpm is not connected, restart the service h2o and php-fpm.

require [Itamae](https://github.com/itamae-kitchen/itamae) simple and lightweight configuration management tool.
