#!/usr/bin/ruby

if node[:dir_user_home].nil? || node[:dir_user_home].empty?
    dir_user_home = '/home/vagrant'
else
    dir_user_home = node[:dir_user_home]
    unless dir_user_home.end_with?("/") then
        dir_user_home << '/'
    end
end

if node[:dir_tmp].nil? || node[:dir_tmp].empty?
    dir_tmp = '/tmp'
else
    dir_tmp = node[:dir_tmp]
    if dir_tmp.end_with?("/") then
        dir_tmp = dir_tmp.slice(0, dir_tmp.length - 1)
    end
end

if node[:php][:version].nil? || node[:php][:version].empty?
    php_version = 'master'
else
    php_version = node[:php][:version]
end

if node[:php][:user].nil? || node[:php][:user].empty?
    php_user = 'nobody'
else
    php_user = node[:php][:user]
end

if node[:php][:group].nil? || node[:php][:group].empty?
    php_group = 'nobody'
else
    php_group = node[:php][:group]
end

if node[:php][:pid].nil? || node[:php][:pid].empty?
    php_pid = '/var/run/php-fpm.pid'
else
    php_pid = node[:php][:pid]
end

if node[:php][:daemonize].nil? || node[:php][:daemonize].empty?
    php_daemonize = 'no'
else
    php_daemonize = node[:php][:daemonize]
end

if node[:php][:expose_php].nil? || node[:php][:expose_php].empty?
    php_expose_php = 'On'
else
    php_expose_php = node[:php][:expose_php]
end

puts "php: dir_user_home: #{dir_user_home}"
puts "php: dir_tmp: #{dir_tmp}"
puts "php: install #{php_version} for Debian/Jessie (use command 'systemctl')"
puts "php: php-fpm exec user: #{php_user}"
puts "php: php-fpm exec group: #{php_group}"
puts "php: php-fpm pid path: #{php_fpm_pid}"
puts "php: php-fpm daemonize: #{php_daemonize}"
puts "php: send php version in http header: #{php_expose_php}"

%w(git autoconf automake libtool make wget bison flex re2c libjpeg-dev libpng12-dev libxml2-dev libbz2-dev libmcrypt-dev libssl-dev libcurl4-openssl-dev libreadline6-dev libtidy-dev libxslt-dev pkg-config).each do |pkg|
    package pkg
end

execute 'install phpenv' do
    command <<-"EOH"
cd #{dir_tmp}
wget -O phpenv.tar.gz https://github.com/madumlao/phpenv/archive/master.tar.gz
tar zxvf phpenv.tar.gz
mv phpenv-master #{dir_user_home}.phpenv
echo 'export PATH="#{dir_user_home}.phpenv/bin:$PATH"' |tee -a #{dir_user_home}.bashrc
echo 'eval "$(phpenv init -)"' |tee -a #{dir_user_home}.bashrc
EOH
    user 'vagrant'
    not_if "ls -la #{dir_user_home} |grep .phpenv"
end

execute 'install php-build' do
    command <<-"EOH"
cd #{dir_tmp}
wget -O php-build.tar.gz https://github.com/php-build/php-build/archive/master.tar.gz
tar zxvf php-build.tar.gz
mkdir -p #{dir_user_home}.phpenv/plugins
mv php-build-master #{dir_user_home}.phpenv/plugins/php-build
EOH
    user 'vagrant'
    not_if "ls #{dir_user_home}.phpenv/plugins |grep php-build"
end

execute 'install php #{php_version}' do
    command <<-"EOH"
cd #{dir_user_home}
export PATH="#{dir_user_home}.phpenv/bin:$PATH"; eval "$(phpenv init -)"; phpenv install #{php_version}
export PATH="#{dir_user_home}.phpenv/bin:$PATH"; eval "$(phpenv init -)"; phpenv global #{php_version}
EOH
    user 'vagrant'
    not_if "ls #{dir_user_home}.phpenv/versions |grep #{php_version}"
end

execute 'php-fpm settings' do
    command <<-"EOH"
sed -i "s/expose_php.*$/expose_php = #{php_expose_php}/" #{dir_user_home}.phpenv/versions/#{php_version}/etc/php.ini

cd #{dir_user_home}
cp #{dir_user_home}.phpenv/versions/#{php_version}/etc/php-fpm.conf.default #{dir_user_home}.phpenv/versions/#{php_version}/etc/php-fpm.conf
sed -i 's%;pid = run/php-fpm.pid%pid = #{dir_user_home}.phpenv/versions/#{php_version}#{php_fpm_pid}%' #{dir_user_home}.phpenv/versions/#{php_version}/etc/php-fpm.conf
sed -i 's%;daemonize = yes%daemonize = #{php_daemonize}%' #{dir_user_home}.phpenv/versions/#{php_version}/etc/php-fpm.conf

cp #{dir_user_home}.phpenv/versions/#{php_version}/etc/php-fpm.d/www.conf.default #{dir_user_home}.phpenv/versions/#{php_version}/etc/php-fpm.d/www.conf
sed -i 's%user = nobody%user = #{php_user}%' #{dir_user_home}.phpenv/versions/#{php_version}/etc/php-fpm.d/www.conf
sed -i 's%group = nobody%group = #{php_group}%' #{dir_user_home}.phpenv/versions/#{php_version}/etc/php-fpm.d/www.conf

cp #{dir_tmp}/php-build/source/#{php_version}/sapi/fpm/php-fpm.service #{dir_tmp}/php-build/source/#{php_version}/sapi/fpm/php-fpm.service.edit
sed -i 's%${prefix}%#{dir_user_home}.phpenv/versions/#{php_version}%' #{dir_tmp}/php-build/source/#{php_version}/sapi/fpm/php-fpm.service.edit
sed -i 's%${exec_prefix}%#{dir_user_home}.phpenv/versions/#{php_version}%' #{dir_tmp}/php-build/source/#{php_version}/sapi/fpm/php-fpm.service.edit
sed -i 's%--nodaemonize%%' #{dir_tmp}/php-build/source/#{php_version}/sapi/fpm/php-fpm.service.edit
cp #{dir_tmp}/php-build/source/#{php_version}/sapi/fpm/php-fpm.service.edit /etc/systemd/system/php-fpm.service
EOH
    not_if "ls -la /usr/lib/systemd/system |grep php-fpm.service"
end

service 'php-fpm' do
    action :start
    only_if 'service php-fpm status 2>&1 |grep stopped'
end
