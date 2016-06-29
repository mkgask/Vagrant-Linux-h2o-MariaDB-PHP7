# Vagrant-Linux-h2o-mysqlenv-phpenv

| type | value |
|------|-------|
| VirtualMachine | Vagrant |
| Supported OS | Ubuntu/Trusty or Debian/Jessie |
| | (If you want to use Ubuntu/Xenial, maybe same settings Debian/Jessie. Not yet confirmed) |
| front | h2o web server |
| app   | phpenv (default:php7.0.7) |
| db    | mysqlenv (default:mariadb-10.1.13) |


Usage:

1. Git clone this repository  
    ``` 
    git clone https://github.com/mkgask/vlhmp.git  
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
    itamae ssh -h 192.168.33.10 -u vagrant -y=itamae/roles/dev/env.yml itamae/roles/dev/setup.rb
    ```

5. Get a coffee and snack break time, because take a long time execute.

If h2o and php-fpm is not connected, restart the service h2o and php-fpm.

require [Itamae](https://github.com/itamae-kitchen/itamae) simple and lightweight configuration management tool.