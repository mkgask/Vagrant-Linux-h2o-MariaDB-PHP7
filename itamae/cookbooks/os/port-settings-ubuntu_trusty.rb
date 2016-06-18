
puts "os: ufw port settings: default deny"
execute "ufw port settings: default deny" do
    command <<-"EOH"
ufw default deny
EOH
end

if node[:expose] then
    node[:expose].each do |key, val|
        
        puts "os: ufw port settings: allow #{key}:#{val}"
        execute "ufw port settings: allow #{key}:#{val}" do
            command <<-"EOH"
ufw allow #{val}
EOH
            not_if "ufw status |grep #{val}"
        end

    end
end

if node[:expose_limit] then
    node[:expose_limit].each do |key, val|
        
        puts "os: ufw port settings: 6 access denied per 30 seconds"
        execute "ufw port settings: 6 access denied per 30 seconds" do
            command <<-"EOH"
ufw limit #{val}
EOH
        end

    end
end

puts "os: ufw reload"
execute "ufw reload" do
    command <<-"EOH"
ufw reload
EOH
    not_if 'ufw status |grep inactive'
end

puts "os: ufw enable"
execute "ufw enable" do
    command <<-"EOH"
echo 'y' | ufw enable
EOH
    only_if 'ufw status |grep inactive'
end
