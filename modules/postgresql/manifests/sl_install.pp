class postgresql::sl_install ( $version, $listen, $port ) {

    $database_directory = "/var/lib/pgsql/${version}/data"
    $bin_dir = "/usr/pgsql-${version}/bin"

    $vd = regsubst($version,'([\d]+)\.([\d]+)','\1\2','G')
    #notice ("Mirror, mirror, tell me true: vd is ${vd}")

	file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG" :
			ensure => file,
			owner  => "root",
			group  => "root",
			mode   => "0444",
			source => "puppet:///modules/postgresql/RPM-GPG-KEY-PGDG-${vd}",
	}
	
	yumrepo {
		"pgdg${vd}" :
			enabled         => 1,
			descr           => "PostgreSQL ${version} \$releasever - \$basearch",
			baseurl         => "http://yum.postgresql.org/${version}/redhat/rhel-\$releasever-\$basearch",
			gpgcheck        => 1,
            gpgkey          => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG',
			require         => File["/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG"];	
		"pgdg${vd}-source" :
			enabled         => 0,
			descr           => "PostgreSQL ${version} \$releasever - \$basearch - source",
			baseurl         => "http://yum.postgresql.org/srpms/${version}/redhat/rhel-\$releasever-\$basearch",
			failovermethod  => "priority",
			gpgcheck        => 1,
            gpgkey          => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG',
			require         => File["/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG"];
	}

    package { [ "postgresql${vd}-server",
                "postgresql${vd}-devel",
                "postgresql${vd}-contrib",
                "postgresql${vd}"
            ]:
            ensure  => installed,
            require => [Yumrepo["pgdg${vd}"],Yumrepo["pgdg${vd}-source"]],
    }

    user { "postgres":
        ensure  => present,
        require => Package["postgresql${vd}-server"],
    }

    #future option: -D data_dir (use pg_ctl command)
    exec { "initdb":
        command => "/sbin/service postgresql-${version} initdb",
        unless  => "/bin/su postgres -c '/usr/pgsql-${version}/bin/pg_ctl status -D ${database_directory}'",
        require => Package["postgresql${vd}-server"],
    }

    #service
    service { "postgresql-${version}":
        ensure     => running,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        require    => [Package["postgresql${vd}-server"],Exec["initdb"]],
    }
   
    #bin files
    file {"/usr/bin/pg_config":
        ensure => "${bin_dir}/pg_config",
        require => Package["postgresql${vd}-server"],
    }

    file {"/usr/bin/psql":
        ensure => "${bin_dir}/psql",
        require => Package["postgresql${vd}-server"],
    }

    file {"/usr/bin/pg_dump":
        ensure => "${bin_dir}/pg_dump",
        require => Package["postgresql${vd}-server"],
    }
    
    file {"/usr/bin/pg_dumpall":
        ensure => "${bin_dir}/pg_dumpall",
        require => Package["postgresql${vd}-server"],
    }
    
    file {"/usr/bin/pg_restore":
        ensure => "${bin_dir}/pg_restore",
        require => Package["postgresql${vd}-server"],
    }

    file {"/usr/bin/pg_ctl":
        ensure => "${bin_dir}/pg_ctl",
        require => Package["postgresql${vd}-server"],
    }

    file {"/usr/bin/createuser":
        ensure => "${bin_dir}/createuser",
        require => Package["postgresql${vd}-server"],
    }

    file {"/usr/bin/createdb":
        ensure => "${bin_dir}/createdb",
        require => Package["postgresql${vd}-server"],
    }

    #hba file
    #TODO: use augeas to add/remove extra entry: https://github.com/foxsoft/puppet-postgresql/
    #pg_hba template approach: http://www.slideshare.net/roidelapluie/postgresql-90-ha
    file { "${database_directory}/pg_hba.conf":
        ensure  => file,
        mode    => "0600",
        owner   => "postgres",
        group   => "postgres",
        source  => "puppet:///modules/postgresql/pg_hba.conf",
        notify  => Service["postgresql-${version}"],
        require => Exec["initdb"],
    }

    #conf file
    #TODO: use augeas to add/remove extra entry: https://github.com/camptocamp/puppet-postgresql/
    file { "${database_directory}/postgresql.conf":
        ensure  => file,
        mode    => "0600",
        owner   => "postgres",
        group   => "postgres",
        content => template("postgresql/postgresql.conf.erb"),
        notify  => Service["postgresql-${version}"],
        require => Exec["initdb"],
    }
}
