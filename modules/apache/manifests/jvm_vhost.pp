define apache::jvm_vhost( $vdomain = "") {
    include apache

    if $vdomain == "" {
        $vhost_domain = $name
    } else {
        $vhost_domain = $vdomain
    }

    # mod_proxy_ajp: http://httpd.apache.org/docs/2.2/mod/mod_proxy_ajp.html
    # mod_proxy_balancer: http://httpd.apache.org/docs/2.2/mod/mod_proxy_balancer.html
    file { "/etc/httpd/conf.d/${vhost_domain}.conf":
        ensure  => file,
        content => template("apache/jvm_vhost.erb"),
        notify  => Service["httpd"],
        require => Package["httpd"],
    }

}
