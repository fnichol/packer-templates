Vagrant.configure(2) do |config|
  # disabled until https://github.com/mitchellh/vagrant/pull/5326 makes it
  # into a release following 1.7.2
  config.ssh.insert_key = false

  ["vmware_fusion", "vmware_workstation"].each do |vmware|
    config.vm.provider vmware do |v, override|
      v.vmx["memsize"] = "3072"
    end
  end
end
