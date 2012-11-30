stage { "base": before   => Stage["tuning"] }
stage { "tuning": before => Stage["main"] }
stage { "last": require  => Stage["main"] }

# Basic
class { "install_repos": stage => "base" }
class { "basic_package": stage => "base" }
class { "user::root": stage    => "base" }

# Hosts
host { "$fqdn":
    ip           => "$ipaddress_eth1",
    host_aliases => "$hostname",
}

# Firewall manage
service { "iptables":
    ensure => running,
    enable => true,
}
exec { 'clear-firewall':
    command     => '/sbin/iptables -F',
    refreshonly => true,        
}
exec { 'persist-firewall':
    command     => '/sbin/iptables-save >/etc/sysconfig/iptables',
    refreshonly => true,
}
Firewall {
    subscribe => Exec['clear-firewall'],
    notify    => Exec['persist-firewall'],
}
class { "basic_firewall": }


# Extra
# Database server manage
# postgresql instance must be created first -> so use stage
class { "postgresql":
    version => "9.1",
    listen  => "localhost, 77.77.77.150",
    port    => "5432",
    stage   => "tuning",
}
# firewall rule can't be inside class postgresql, because require same
# stage as exec clear/persist-firewall
firewall { "100 allow postgresql":
    state  => ["NEW"],
    dport  => "5432",
    proto  => "tcp",
    action => accept,
}
file { "/var/lib/pgsql/sql_sesame":
    ensure  => directory,
    mode    => "0644",
    owner   => "postgres",
    group   => "postgres",
}


# TODO: any change should also update user
# ALTER USER postgres WITH PASSWORD '${POSTGRESQL_POSTGRES_PASSWORD}';
pg_user { 'cave':
    ensure   => present,
    password => 'cave',
}
pg_database { 'cave':
    ensure  => present,
    owner   => 'cave',
    require => Pg_user['cave'],
}

postgresql::db { 'wine_cellar':
    password => 'wine_cellar',
}
file { "/var/lib/pgsql/sql_sesame/winelist.sql":
    ensure => file,
    mode   => "0644",
    owner  => "postgres",
    group  => "postgres",
    source => "/vagrant/samples/java_app/database/winelist.sql",
}
exec { 'su - postgres -c "psql -d wine_cellar -U wine_cellar -f /var/lib/pgsql/sql_sesame/winelist.sql"':
    path        => "/bin:/sbin:/usr/bin:/usr/sbin",
    refreshonly => true,
    subscribe   => File["/var/lib/pgsql/sql_sesame/winelist.sql"],
    require     => Postgresql::Db["wine_cellar"],
}
