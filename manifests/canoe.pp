stage { "base": before => Stage["main"] }
stage { "last": require => Stage["main"] }

# Basic
class { "install_repos": stage => "base" }
class { "basic_package": stage => "base" }
class { "user::root": stage    => "base" }

# Hosts
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
# Apache Manage
class { "apache": }
firewall { "100 allow apache":
        state  => ['NEW'],
        dport  => '80',
        proto  => 'tcp',
        action => accept,
}

# Add to /etc/hosts on your host (e.g. desktop): 77.77.77.171 canoe_red.qq canoe_blue.qq bering.sea
apache::jvm_vhost { "bering.sea": }

apache::vhost { "canoe_red.qq": }
file { "/var/www/html/canoe_red.qq/index.html":
    ensure  => file,
    owner   => "root",
    group   => "apache",
    mode    => "0640",
    content => "<html>vhost - canoe_red.qq</html>",
    require => Apache::Vhost["canoe_red.qq"],
}
apache::vhost { "canoe_blue.qq": }
file { "/var/www/html/canoe_blue.qq/index.html":
    ensure  => file,
    owner   => "root",
    group   => "apache",
    mode    => "0640",
    content => "<html>vhost - canoe_blue.qq</html>",
    require => Apache::Vhost["canoe_blue.qq"],
}
