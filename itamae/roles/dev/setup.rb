#!/usr/bin/ruby

path_recipe_base = '../../cookbooks/'

puts 'os: default setup'
include_recipe path_recipe_base + 'os/set-timezone.rb'
include_recipe path_recipe_base + 'os/update-upgrade.rb'

if node[:h2o] then
    include_recipe path_recipe_base + 'h2o/install-ubuntu_trusty.rb'
end

if node[:php] then
    include_recipe path_recipe_base + 'php/install-ubuntu_trusty.rb'
end

if node[:mysql] then
    #include_recipe path_recipe_base + 'mysql/install.rb'
end
