puts "os: upgrade"

execute "upgrade to os" do
    command <<-"EOH"
apt-get dist-upgrade -y
EOH
end
