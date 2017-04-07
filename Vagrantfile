Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/xenial64"
    config.vm.network "private_network", ip: "192.168.33.71"
    config.vm.synced_folder "./", "/storage", type: "nfs"
    config.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
    end
end
