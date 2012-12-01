stage { "base": before => Stage["main"] }
stage { "last": require => Stage["main"] }

# Basic
class { "install_repos": stage => "base" }
class { "basic_package": stage => "base" }
class { "user::root": stage    => "base"}

# Hosts
host { "$fqdn":
    ip           => "$ipaddress_eth1",
    host_aliases => "$hostname",
}

host { "mammoth.farm":
    ip           => "77.77.77.150",
    host_aliases => "mammoth",
}

# Firewall Manage
service { "iptables":
    ensure => running,
    enable => true,
}
exec { "clear-firewall":
    command     => '/sbin/iptables -F',
    refreshonly => true,        
}
exec { "persist-firewall":
    command     => "/sbin/iptables-save >/etc/sysconfig/iptables",
    refreshonly => true,
}
Firewall {
    subscribe => Exec['clear-firewall'],
    notify    => Exec['persist-firewall'],
}
class { "basic_firewall": }


# Extra
# Tomcat Manage
$routeid = regsubst($hostname,'([\w]+)([0-9]{2})','\2','G')
notice ("Mirror, mirror, tell me true: routeid is ${routeid}")

class { "tomcat6": 
    jvmroute => "jvm${routeid}",
}

# localhost is the default virtual host in server.xml.erb, 
# if you need other virt_host edit that file manualy
tomcat6::virt_host { "localhost":
    appBase   => "my_webapps",
    warBase   => "my_wars",
    appSource => "/vagrant/samples/java_app",
}
# test multiple virt_host:
/*
tomcat6::virt_host { "localhost2":
    appBase   => "my_webapps2",
    warBase   => "my_wars2",
    appSource => "/vagrant/samples/java_app",
    host_name => "localhost2",
}
*/

firewall { '100 allow tomcat http':
    state  => ['NEW'],
    dport  => '8080',
    proto  => 'tcp',
    action => accept,
}
firewall { '100 allow tomcat ajp':
    state  => ['NEW'],
    dport  => '8009',
    proto  => 'tcp',
    action => accept,
}

