stage { "base": before => Stage["main"] }
stage { "tuning": before => Stage["main"] }
stage { "last": require => Stage["main"] }

#basic
class { "install_repos": stage => "base" }
class { "basic_package": stage => "base" }
class { "user::root": stage    => "base"}

#hosts:
host { "$fqdn":
    ip          => "$ipaddress_eth1",
    host_aliases => "$hostname",
}

host { "mammoth.farm":
    ip          => "77.77.77.150",
    host_aliases => "mammoth",
}

#firewall manage
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

#tomcat manage
class { "tomcat6": }

firewall { '100 allow tomcat':
    state  => ['NEW'],
    dport  => '8080',
    proto  => 'tcp',
    action => accept,
}
