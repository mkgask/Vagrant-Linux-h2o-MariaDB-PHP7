puts "os: set timezone: #{node[:timezone]}"

execute "os initialize" do
    command <<-"EOH"
echo #{node[:timezone]} |tee /etc/timezone
EOH
    not_if "cat /etc/timezone |grep #{node[:timezone]}"
end
