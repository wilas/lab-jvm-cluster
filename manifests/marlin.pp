stage { "base": before => Stage["main"] }
stage { "last": require => Stage["main"] }

# Basic
class { "install_repos": stage => "base" }
class { "basic_package": stage => "base" }
class { "user::root": stage    => "base"}

# Hosts
host { "$fqdn":
    ip          => "$ipaddress_eth1",
    host_aliases => "$hostname",
}

host { "mammoth.farm":
    ip          => "77.77.77.150",
    host_aliases => "mammoth",
}

# Firewall Manage
service { "iptables":
    ensure => running,
    enable => true,
}
exec { 'clear-firewall':
    command => '/sbin/iptables -F',
    refreshonly => true,        
}
exec { 'persist-firewall':
    command => '/sbin/iptables-save >/etc/sysconfig/iptables',
    refreshonly => true,
}
Firewall {
    subscribe => Exec['clear-firewall'],
    notify => Exec['persist-firewall'],
}
class { "basic_firewall": }


# Extra
# Tomcat Manage
$routeid = regsubst($hostname,'([\w]+)([0-9]{2})','\2','G')
notice ("Mirror, mirror, tell me true: routeid is ${routeid}")

class { "tomcat6": 
    jvmroute => "jvm${routeid}",
}
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
