puts "os: update"

execute "update to os" do
    command <<-"EOH"
apt-get update -y
EOH
end
