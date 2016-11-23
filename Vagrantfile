# -*- mode: ruby -*-
# vi: set ft=ruby :

guestname                   = "DC1"
guestip                     = "192.168.5.1" # try don't use *.1, vagrant complains; but samba might what *.1 
domainname                  = "EN63366"
realm                       = "EN63366.local"
adminpass                   = "E97GpFhkMFzAu55DSFL"
vagrant_network_dns_address = "10.0.2.3"

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "debian/jessie64"

  config.vm.hostname = guestname
  config.vm.network "private_network", ip: guestip,
    virtualbox__intnet: true

  # Resolve dns 
  # vagrant_network_dns_address = Socket::getaddrinfo(config.vm.hostname, 'http', nil, Socket::SOCK_STREAM)[0][3]

  config.vm.synced_folder ".", "/vagrant", type: "rsync", disabled:true
  config.vm.synced_folder "./data", "/vagrant_data", type: "virtualbox"

  # <<-taking care of dns resolution configuration 
  config.vm.provision "shell", keep_color: true, run: "always", 
    inline: %{sed -i "s/.*#{guestname}/#{guestip}    #{guestname}.#{realm}    #{guestname}/" /etc/hosts}

  config.vm.provision "shell", keep_color: true, 
    inline: %{
      echo 'dns-domain #{realm}' >> /etc/network/interfaces
      echo 'dns-nameservers #{guestip}' >> /etc/network/interfaces
    }

  config.vm.provision "shell", keep_color: true, 
    inline: %{
      sed -i "s/\#supersede domain-name.*/supersede domain-name \"#{realm}\";/" /etc/dhcp/dhclient.conf
      sed -i "s/\#prepend domain-name-servers.*/prepend domain-name-servers #{guestip};/" /etc/dhcp/dhclient.conf
      dhclient
    }
  # DONE: taking care of dns resolution configuration

  # make sure that aptitude is up to date 
  config.vm.provision "shell", keep_color: true, 
    inline: "apt-get update"
  # install samba, before winbind
  config.vm.provision "shell", keep_color: true, 
    inline: "apt-get install -y samba winbind smbclient"
  # # unattedentd install of krb5-user
  # config.vm.provision "shell", keep_color: true, 
  #   inline: %{
  #     export DEBIAN_FRONTEND=noninteractive
  #     apt-get install -y krb5-user
  #   }

  # unattedentd domain controller config
  config.vm.provision "shell", keep_color: true, 
    inline: %{
      rm -f /etc/samba/smb.conf
      samba-tool domain provision --use-rfc2307 --realm=#{realm} --domain=#{domainname} --server-role=dc --adminpass=#{adminpass} --option="interfaces=lo eth1" --option="bind interfaces only=yes"
      sed -i "s/\sdns forwarder =.*/dns forwarder = ' + #{vagrant_network_dns_address} + '/" /etc/samba/smb.conf
      /etc/init.d/samba restart
    }

  # testing that DNS works correctly
  config.vm.provision "shell", keep_color: true, run: "always", 
    inline: %{
      host -t SRV _ldap._tcp.#{realm}.
      host -t SRV _kerberos._udp.#{realm}.
      host -t A #{guestname}.#{realm}.
    }

  # config.vm.provision "shell", 
  #   inline: %{
  #     rm /etc/krb5.conf 2> nul
  #     ln -sf /var/lib/samba/private/krb5.conf /etc/krb5.conf
  #   }

end
