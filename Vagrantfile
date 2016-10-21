# -*- mode: ruby -*-
# vi: set ft=ruby :

guestname = "DC1"
guestip   = "192.168.5.1" # try don't use *.1, vagrant complains; but samba might what *.1 
domainname= "EN63366"
realm     = "EN63366.local"


# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "debian/jessie64"

  config.vm.hostname = guestname

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network "private_network", ip: guestip,
    virtualbox__intnet: true

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder ".", "/vagrant", type: "rsync", disabled:true
  config.vm.synced_folder "./data", "/vagrant_data", type: "virtualbox"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  modifyHosts = 'sed -i "s/.*' + guestname + '/' + guestip + '    ' + guestname + '.' + realm + '    ' + guestname + '/" /etc/hosts'
  config.vm.provision "shell", run: "always", inline: modifyHosts

  addDomainToDnsInfo = "echo 'dns-domain " + realm + "' >> /etc/network/interfaces\n"
  addDomainToDnsInfo = addDomainToDnsInfo + "echo 'dns-nameservers " + guestip + "' >> /etc/network/interfaces" 
  config.vm.provision "shell", inline: addDomainToDnsInfo

  addDomainToDnsInfo = 'sed -i "s/\#supersede domain-name.*/supersede domain-name \"' + realm + '\";/" /etc/dhcp/dhclient.conf' + "\n"
  addDomainToDnsInfo = addDomainToDnsInfo + 'sed -i "s/\#prepend domain-name-servers.*/prepend domain-name-servers ' + guestip + ';/" /etc/dhcp/dhclient.conf' + "\n"
  addDomainToDnsInfo = addDomainToDnsInfo + 'dhclient'
  config.vm.provision "shell", inline: addDomainToDnsInfo

  config.vm.provision "shell", inline: <<-SHELL
   apt-get update
   apt-get install -y samba
   rm -f /etc/samba/smb.conf
   samba-tool domain provision --use-rfc2307 --realm=EN63366.local --domain=EN63366 --server-role=dc --adminpass=E97GpFhkMFzAu55DSFL --option="interfaces=lo eth1" --option="bind interfaces only=yes"
   apt-get install -y smbclient
   apt-get install -y winbind
  
   # echo "domain EN63366.local" > /etc/resolv.conf
   # echo "nameserver 192.168.5.2" >> /etc/resolv.conf 
  
   # host -t SRV _ldap._tcp.EN63366.local.
   # host -t SRV _kerberos._udp.EN63366.local.
   # host -t A DC1.EN63366.local.
  
  SHELL
end
