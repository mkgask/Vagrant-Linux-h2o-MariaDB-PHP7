dir_user_home = node[:dir_user_home]
unless dir_user_home.end_with?("/") then
    dir_user_home << '/'
end

dir_tmp = node[:dir_tmp]
if dir_tmp.end_with?("/") then
    dir_tmp = dir_tmp.slice(0, dir_tmp.length - 1)
end

php_version = '7.0.7'
if node.has_key?("optional") && node[:optional].has_key?("php_version") && node[:optional][php_version] then
    php_version = node[:optional][php_version]
end

php_user = 'www-data'
if node.has_key?("optional") && node[:optional].has_key?("php_user") && node[:optional][php_user] then
    php_user = node[:optional][php_user]
end

php_group = 'www-data'
if node.has_key?("optional") && node[:optional].has_key?("php_group") && node[:optional][php_group] then
    php_group = node[:optional][php_group]
end

php_fpm_pid = '/var/run/php-fpm.pid'
if node.has_key?("optional") && node[:optional].has_key?("php_fpm_pid") && node[:optional][php_fpm_pid] then
    php_fpm_pid = node[:optional][php_fpm_pidphp_fpm_pid]
end

php_daemonize = 'yes'
if node.has_key?("optional") && node[:optional].has_key?("php_daemonize") && node[:optional][php_daemonize] then
    php_daemonize = node[:optional][php_daemonize]
end

php_expose_php = 'Off'
if node.has_key?("optional") && node[:optional].has_key?("php_expose_php") && node[:optional][php_expose_php] then
    php_expose_php = node[:optional][php_expose_php]
end

puts "php70: install #{php_version} for Debian/Jessie (use command 'systemctl')"
puts "php70: php-fpm exec user: #{php_user}"
puts "php70: php-fpm exec group: #{php_group}"
puts "php70: php-fpm pid path: #{php_fpm_pid}"
puts "php70: php-fpm daemonize: #{php_daemonize}"
puts "php70: send php version in http header: #{php_expose_php}"

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
    not_if "ls -la #{dir_user_home}.phpenv/plugins |grep php-build"
end

execute 'build php70' do
    command <<-"EOH"
cd #{dir_user_home}
export PATH="#{dir_user_home}.phpenv/bin:$PATH"; eval "$(phpenv init -)"; phpenv install #{php_version}
export PATH="#{dir_user_home}.phpenv/bin:$PATH"; eval "$(phpenv init -)"; phpenv global #{php_version}
EOH
    user 'vagrant'
    not_if "ls -la #{dir_user_home}.phpenv/versions |grep #{php_version}"
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
