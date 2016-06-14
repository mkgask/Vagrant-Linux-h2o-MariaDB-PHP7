puts "os: upgrade"

execute "upgrade to os" do
    command <<-"EOH"
apt-get upgrade -y
EOH
end
