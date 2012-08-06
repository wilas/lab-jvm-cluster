define apache::vhost( $vdomain = "", $documentroot = "" ) {
    include apache

    if $vdomain == "" {
        $vhost_domain = $name
    } else {
        $vhost_domain = $vdomain
    }

    if $documentroot == "" {
        $vhost_root = "/var/www/html/${name}"
    } else {
        $vhost_root = $documentroot
    }

    file { "/etc/httpd/conf.d/${vhost_domain}.conf":
        ensure  => file,
        content => template("apache/vhost.erb"),
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

    file { "${vhost_root}":
        ensure => directory,
        owner  => "root",
        group  => "apache",
        mode   => "0640",
        require => Package["httpd"],
    }
}
