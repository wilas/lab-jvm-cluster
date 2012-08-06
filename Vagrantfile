# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  
  config.vm.define :mammoth do |db_config|  
    vm_name= "mammoth"
    db_config.vm.box = "SL64_box"
    db_config.vm.host_name = "#{vm_name}.farm"
    db_config.vm.customize ["modifyvm", :id, "--memory", "512", "--name", "#{vm_name}"]
  
    db_config.vm.network :hostonly, "77.77.77.150"
    db_config.vm.share_folder "v-root", "/vagrant", "."

    db_config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file  = "mammoth.pp"
        puppet.module_path = "modules"
    end
  end

  config.vm.define :marlin01 do |app_config|  
    vm_name= "marlin01"
    app_config.vm.box = "SL64_box"
    app_config.vm.host_name = "#{vm_name}.farm"
    app_config.vm.customize ["modifyvm", :id, "--memory", "512", "--name", "#{vm_name}"]
  
    app_config.vm.network :hostonly, "77.77.77.160"
    app_config.vm.share_folder "v-root", "/vagrant", "."
    app_config.vm.forward_port 8080, 6088

    app_config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file  = "marlin.pp"
        puppet.module_path = "modules"
    end
  end

  config.vm.define :canoe01 do |web_config|  
    vm_name= "canoe01"
    web_config.vm.box = "SL64_box"
    web_config.vm.host_name = "#{vm_name}.farm"
    web_config.vm.customize ["modifyvm", :id, "--memory", "512", "--name", "#{vm_name}"]
  
    web_config.vm.network :hostonly, "77.77.77.170"
    web_config.vm.share_folder "v-root", "/vagrant", "."
    web_config.vm.forward_port 80, 5080

    web_config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file  = "canoe.pp"
        puppet.module_path = "modules"
    end
  end

end
