Vagrant.configure(2) do |config|
  config.ssh.shell = "/bin/sh"
  config.ssh.sudo_command = "doas %c"
  config.vm.synced_folder ".", "/vagrant",
    type: "rsync",
    rsync__rsync_path: "doas rsync"
end
