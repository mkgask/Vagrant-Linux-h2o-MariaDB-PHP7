#!/usr/bin/ruby

dir_user_home = node[:dir_user_home]
unless dir_user_home.end_with?("/") then
    dir_user_home << '/'
end

dir_tmp = node[:dir_tmp]
if dir_tmp.end_with?("/") then
    dir_tmp = dir_tmp.slice(0, dir_tmp.length - 1)
end

h2o_version = node[:h2o][:version]
if !h2o_version then
    h2o_version = '2.0.0'
end

h2o_user = node[:h2o][:user]
if !h2o_user then
    h2o_user = 'nobody'
end

h2o_pid = node[:h2o][:pid]
if !h2o_pid then
    h2o_pid = '/var/run/h2o/h2o.pid'
end

puts "h2o: build & install #{h2o_version} for Debian/Jessie (use command 'systemctl')"
puts "h2o: exec user: #{h2o_user}"
puts "h2o: pid: #{h2o_pid}"

%w(cmake g++ libcurl4-openssl-dev libcrypto++-dev).each do |pkg|
    package pkg
end

execute 'build & install h2o web server' do
    command <<-'EOH'
cd #{dir_tmp}
wget -O h2o-#{h2o_version}.tar.gz https://github.com/h2o/h2o/archive/v#{h2o_version}.tar.gz
tar zxvf h2o-#{h2o_version}.tar.gz
cd h2o-#{h2o_version}
cmake -DWITH_BUNDLED_SSL=on .
make
make install
mkdir -p /var/log/h2o
mkdir -p /var/run/h2o
mkdir -p /etc/h2o
EOH
end

remote_file '/etc/h2o/h2o.conf' do
    user 'root'
    source 'files/h2o.conf'
end

execute 'setting h2o.conf' do
    command <<-'EOH'
cd #{dir_tmp}
sed -i 's%user: www-data%user: #{h2o_user}%' /etc/h2o/h2o.conf
sed -i 's%/var/run/h2o/h2o.pid%#{h2o_pid%' /etc/h2o/h2o.conf
EOH
    not_if "cat /etc/h2o/h2o.conf |grep #{h2o_user}"
end

remote_file '/usr/lib/systemd/system/h2o.service' do
    source 'files/h2o.service'
end

execute 'setting init.d/h2o' do
    command <<-"EOH"
cd #{dir_tmp}
sed -i 's%/var/run/h2o/h2o.pid%#{h2o_pid%' /usr/lib/systemd/system/h2o.service
EOH
    not_if "cat /usr/lib/systemd/system/h2o.service |grep #{h2o_user}"
end

service 'h2o' do
    action :start
end
