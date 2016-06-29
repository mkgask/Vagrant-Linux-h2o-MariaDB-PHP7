#!/usr/bin/ruby

require __dir__ + '/defs.rb'

port_settings_filenames  = setup_filenames('port-settings', node['platform'], node['platform_version'], '.rb')
setup_filenames = setup_filenames('install', node['platform'], node['platform_version'], '.rb')
#puts 'setup_filenames: ' << setup_filenames.to_s

path_recipe_base = '../../cookbooks/'

puts 'os: default setup'
install 'os', port_settings_filenames, path_recipe_base
include_recipe path_recipe_base + 'os/set-timezone.rb'
include_recipe path_recipe_base + 'os/update-upgrade.rb'
include_resipe path_recipe_base + 'os/install-default-package.rb'

if node[:h2o] then
    install 'h2o', setup_filenames, path_recipe_base
end

if node[:php] then
    install 'php', setup_filenames, path_recipe_base
end

if node[:mysql] then
    install 'mysql', setup_filenames, path_recipe_base
end
