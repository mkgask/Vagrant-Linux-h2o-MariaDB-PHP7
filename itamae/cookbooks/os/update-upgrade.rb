puts "os: update"

execute "update to os" do
    command <<-"EOH"
apt-get update -y
apt-get upgrade -y
apt-get autoremove -y
apt-get autoclean -y
EOH
end
