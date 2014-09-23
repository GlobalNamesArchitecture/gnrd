# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box ="trusty64"
  # config.vm.provision :shell, :path => "cookbooks/bootstrap.sh"
  # config.berkshelf.enabled = true

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty"\
    "/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.provider :virtualbox do |vb|
    vb.memory = 2048
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network :forwarded_port, guest: 80, host: 4567

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      gnrd: {
        server_name: 'gnrd',
        directory: '/vagrant',
        worker_count: 2,
        thin_count: 2,
        salt: '15h7j7g4j3k4j5h6g7ngjgh',
         
      },
      rbenv: {
        'global' => '1.9.3-p429',
        'rubies' => [ '1.9.3-p429' ],
        'gems'   => {
        '1.9.3-p429' => [
          { 'name'   => 'bundler' },
          ]
        }
      },
      mysql: {
        gnrd_user: 'gnrd',
        gnrd_user_password: 'gnrd_pass',
        server_debian_password: 'aadafy35dfs', 
        server_root_password: '',
        server_repl_password: 'aslljm48098'
      }
    }
    chef.log_level = 'debug'

    chef.add_recipe 'apt'
    chef.add_recipe 'build-essential'
    chef.add_recipe 'git'
    chef.add_recipe 'ruby_build'
    chef.add_recipe 'rbenv::system'
    chef.add_recipe 'vim'
    chef.add_recipe 'openssl'
    chef.add_recipe 'apache2'
    chef.add_recipe "mysql::client"
    chef.add_recipe "mysql::server"
    chef.add_recipe 'NetiNeti'
    chef.add_recipe 'taxonfinder'
    chef.add_recipe 'gnrd'
  end
  
end
