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

if node[:mysql][:version].nil? || node[:mysql][:version].empty?
    mysql_version = 'mariadb-10.1.13'
else
    mysql_version = node[:mysql][:version]
end

puts "mysql: dir_user_home: #{dir_user_home}"
puts "mysql: dir_tmp: #{dir_tmp}"
puts "mysql: install #{mysql_version}"

%w(cmake mysql-client build-essential dpkg-dev devscripts hardening-wrapper autoconf automake1.9 autotools-dev binutils bison chrpath debhelper doxygen dpatch dvipdfmx fakeroot fontconfig-config g++ gawk gcc gettext ghostscript ghostscript-x gsfonts html2text intltool-debian libc6-dev libcroco3 libcups2 libcupsimage2 libfontconfig1 libfontenc1 libfreetype6 libgomp1 libice6 libjpeg62 libltdl7 libltdl7-dev libmail-sendmail-perl libncurses5-dev libpaper-utils libpaper1 libpng12-0 libsm6 libsys-hostname-long-perl libtool libwrap0-dev libxaw7 libxfont1 libxmu6 libxpm4 libxt6 linux-libc-dev lmodern m4 make patchutils po-debconf tex-common texlive-base texlive-base-bin texlive-latex-base texlive-latex-base-doc ttf-dejavu ttf-dejavu-core ttf-dejavu-extra xfonts-encodings xfonts-utils zlib1g-dev).each do |pkg|
    package pkg
end

execute 'install mysqlenv' do
    command <<-"EOH"
cd #{dir_tmp}
wget -O mysqlenv.tar.gz https://github.com/shim0mura/mysqlenv/archive/master.tar.gz
tar zxvf mysqlenv.tar.gz
mv mysqlenv-master #{dir_user_home}.mysqlenv
chown -R vagrant:vagrant #{dir_user_home}.mysqlenv
echo 'export PATH="#{dir_user_home}.mysqlenv:$PATH"' |tee -a #{dir_user_home}.bashrc
echo 'eval "$(mysqlenv init -)"' |tee -a #{dir_user_home}.bashrc
cd #{dir_user_home}
EOH
    not_if "ls -la #{dir_user_home} |grep .mysqlenv"
end

execute 'install mysql-build' do
    command <<-"EOH"
cd #{dir_tmp}
wget -O mysql-build.tar.gz https://github.com/kamipo/mysql-build/archive/master.tar.gz
tar zxvf mysql-build.tar.gz
mv mysql-build-master mysql-build
mv mysql-build #{dir_user_home}.mysqlenv
chown -R vagrant:vagrant #{dir_user_home}.mysqlenv/mysql-build
cd #{dir_user_home}
EOH
    not_if "ls -la #{dir_user_home}.mysqlenv/mysql-build |grep bin"
end

execute 'mysqlenv settings' do
    command <<-"EOH"
sed -i 's|http://archive\.mariadb\.org.\+#{mysql_version}\.tar\.gz|https://downloads.mariadb.org/interstitial/#{mysql_version}/source/#{mysql_version}.tar.gz|' #{dir_user_home}.mysqlenv/mysql-build/share/mysql-bulid/definitions/#{mysql_version}
export PATH=#{dir_user_home}.mysqlenv:$PATH; eval "$(mysqlenv init -)"; mysqlenv install #{mysql_version}
export PATH=#{dir_user_home}.mysqlenv:$PATH; eval "$(mysqlenv init -)"; mysqlenv global #{mysql_version}
EOH
end

service 'mysql' do
    action :start
    only_if 'service mysql status |grep stopped'
end
