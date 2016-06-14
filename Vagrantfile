Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/trusty64"
    config.vm.network "private_network", ip: "192.168.33.13"
    #config.vm.synced_folder "./", "/vagrant", type: "nfs"
    config.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
    end
end
