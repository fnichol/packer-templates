Vagrant.configure(2) do |config|
  config.ssh.shell = "/bin/sh"

  config.vm.synced_folder ".", "/vagrant", disabled: true
end
