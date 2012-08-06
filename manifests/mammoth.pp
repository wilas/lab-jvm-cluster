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

#DB manage
class { "postgresql":
    version => "9.1",
    listen  => "localhost, 77.77.77.150",
    port    => "5432",
    stage   => "tuning",
}

firewall { '100 allow postgresql':
    state  => ['NEW'],
    dport  => '5432',
    proto  => 'tcp',
    action => accept,
}

#
#fix it -> should also update user
#ALTER USER postgres WITH PASSWORD '${POSTGRESQL_POSTGRES_PASSWORD}';
#
pg_user { 'cave':
    ensure   => present,
    password => 'cave',
}

pg_database { 'cave':
    ensure  => present,
    owner   => 'cave',
    require => Pg_user['cave'],
}

postgresql::db { 'testme':
    password => 'testme',
}

file { "/root/.pgpass":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => 0600,
    source => "/vagrant/tools/pgpass-root",
}

exec { 'su - postgres -c "psql -d testme -U testme -f /vagrant/samples/simple_app/database/testme.sql"':
    path => "/bin:/sbin:/usr/bin:/usr/sbin",
    require => Postgresql::Db["testme"],
}
