stage { "first": before => Stage["main"] }
stage { "last": require => Stage["main"] }

#basic
class { "install_repos": stage  => "first" }
class { "basic_package": }
class { "user::root": }

#hosts:
host { "$fqdn":
    ip          => "$ipaddress_eth1",
    host_aliases => "$hostname",
}

host { "marlin01.farm":
    ip          => "77.77.77.161",
    host_aliases => "marlin01",
}

host { "marlin02.farm":
    ip          => "77.77.77.162",
    host_aliases => "marlin02",
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

# Extra
class { "apache": }
# Add to /etc/hosts on your host: 77.77.77.171 canoe.me canoe.to marlinschool.me
apache::jvm_vhost { "marlinschool.me": }
apache::vhost { "canoe.me": }
file { "/var/www/html/canoe.me/index.html":
    ensure  => file,
    owner   => "root",
    group   => "apache",
    mode    => "0640",
    content => "<html>vhost - canoe.me</html>",
    require => Apache::Vhost["canoe.me"],
}
apache::vhost { "canoe.to": }
file { "/var/www/html/canoe.to/index.html":
    ensure  => file,
    owner   => "root",
    group   => "apache",
    mode    => "0640",
    content => "<html>vhost - canoe.to</html>",
    require => Apache::Vhost["canoe.to"],
}
