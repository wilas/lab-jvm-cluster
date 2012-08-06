stage { "first": before => Stage["main"] }
stage { "last": require => Stage["main"] }

#basic
class { "install_repos": stage  => "first" }
class { "basic_package": }
class { "user::root": }

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

#write own selinux lib -> this rm link /etc/sysconfig/selinux -> /etc/selinux/config
#class { "selinux": 
#    mode => "disabled"
#}

#extra
class { "apache": }
#edit /etc/hosts -> add 77.77.77.50 canoe.me canoe.to
apache::vhost { "canoe.me": }
apache::vhost { "canoe.to": }
