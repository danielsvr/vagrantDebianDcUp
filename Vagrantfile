# -*- mode: ruby -*-
# vi: set ft=ruby :

guestname = "DC1"
guestip   = "192.168.5.1" # try don't use *.1, vagrant complains; but samba might what *.1 
domainname= "EN63366"
realm     = "EN63366.local"


Vagrant.configure("2") do |config|
  config.vm.box = "debian/jessie64"

  config.vm.hostname = guestname
  config.vm.network "private_network", ip: guestip,
    virtualbox__intnet: true

  config.vm.synced_folder ".", "/vagrant", type: "rsync", disabled:true
  config.vm.synced_folder "./data", "/vagrant_data", type: "virtualbox"

  # <<-taking care of dns resolution configuration 
  modifyHosts = 'sed -i "s/.*' + guestname + '/' + guestip + '    ' + guestname + '.' + realm + '    ' + guestname + '/" /etc/hosts'
  config.vm.provision "shell", keep_color: true, run: "always", inline: modifyHosts

  addDomainToDnsInfo = "echo 'dns-domain " + realm + "' >> /etc/network/interfaces\n"
  addDomainToDnsInfo = addDomainToDnsInfo + "echo 'dns-nameservers " + guestip + "' >> /etc/network/interfaces" 
  config.vm.provision "shell", keep_color: true, inline: addDomainToDnsInfo

  addDomainToDnsInfo = 'sed -i "s/\#supersede domain-name.*/supersede domain-name \"' + realm + '\";/" /etc/dhcp/dhclient.conf' + "\n"
  addDomainToDnsInfo = addDomainToDnsInfo + 'sed -i "s/\#prepend domain-name-servers.*/prepend domain-name-servers ' + guestip + ';/" /etc/dhcp/dhclient.conf' + "\n"
  addDomainToDnsInfo = addDomainToDnsInfo + 'dhclient'
  config.vm.provision "shell", keep_color: true, inline: addDomainToDnsInfo
  # DONE: taking care of dns resolution configuration

  # make sure that aptitude is up to date 
  config.vm.provision "shell", keep_color: true, inline: "apt-get update"
  # install samba, before winbind
  config.vm.provision "shell", keep_color: true, inline: "apt-get install -y samba"
  # install winbind
  config.vm.provision "shell", keep_color: true, inline: "apt-get install -y winbind"
  # install sambclient, for testing
  config.vm.provision "shell", keep_color: true, inline: "apt-get install -y smbclient"

  # unattedentd domain controller config
  config.vm.provision "shell", keep_color: true, inline: <<-SHELL
rm -f /etc/samba/smb.conf
samba-tool domain provision --use-rfc2307 --realm=EN63366.local --domain=EN63366 --server-role=dc --adminpass=E97GpFhkMFzAu55DSFL --option="interfaces=lo eth1" --option="bind interfaces only=yes"

/etc/init.d/samba restart
SHELL

  # testing that DNS works correctly
  config.vm.provision "shell", keep_color: true, run: "always", inline: <<-SHELL
host -t SRV _ldap._tcp.EN63366.local.
host -t SRV _kerberos._udp.EN63366.local.
host -t A DC1.EN63366.local.
SHELL

  config.vm.provision "shell", inline: <<-SHELL
rm /etc/krb5.conf 2> nul
ln -sf /usr/local/samba/private/krb5.conf /etc/krb5.conf
SHELL

end
