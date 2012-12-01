#
# The official Tomcat page is your friend: http://tomcat.apache.org/
# Tomcat 6.0.35 is the current version of this writing. 
#
# Remember to set up firewall rules in tomcat_node configuration or in other specific modu
#

class tomcat6 ( $jvmroute="" ) {

    $version = "6.0.35"
    $jvm_home = "/usr/lib/jvm/java/"
    $catalina_home = "/opt/tomcat"
    $catalina_user = "tomcat"
    
    $engine_dir = "${catalina_home}/conf/Catalina"

    # tomcat engine
    if $jvmroute == ""{
        $engine_opt = "<Engine name=\"Catalina\" defaultHost=\"localhost\">"
    }
    else { 
        $engine_opt = "<Engine name=\"Catalina\" defaultHost=\"localhost\" jvmRoute=\"${jvmroute}\">"
    }

    # install java
    package { "java":
        name   => ["java-1.6.0-openjdk", "java-1.6.0-openjdk-devel"],
        ensure => installed,
    }

    # useradd -s /sbin/nologin -g tomcat -d /path/to/tomcat tomcat
    user { "${catalina_user}":
        ensure  => present,
        shell   => "/sbin/nologin",
        uid     => "333",
        system  => true,
        gid     => "${catalina_user}",
        home    => "${catalina_home}",
        require => Group["${catalina_user}"],
    }

    group { "${catalina_user}":
        ensure => present,
        gid    => "333",
        system => true,
    }

    file { "tomcat package":
        path   => "/opt/apache-tomcat-${version}.tar.gz",
        ensure => present,
        owner  => "root",
        group  => "root",
        mode   => "0644",
        source => "puppet:///modules/tomcat6/apache-tomcat-${version}.tar.gz",
    }

    exec { "unzip tomcat":
        command => "/bin/tar -xvzf /opt/apache-tomcat-${version}.tar.gz -C /opt",
        creates => "/opt/apache-tomcat-${version}",
        require => [File["tomcat package"],User["${catalina_user}"]],
    }

    file { "chmod -R tomcat:tomcat apache-tomcat":
        ensure  => directory,
        path    => "/opt/apache-tomcat-${version}",
        owner   => "${catalina_user}",
        group   => "${catalina_user}",
        recurse => true, 
        require => [Exec["unzip tomcat"],User["${catalina_user}"]],
    }

    file { "${catalina_home}":
        ensure  => link,
        target  => "/opt/apache-tomcat-${version}",
        owner   => "${catalina_user}",
        group   => "${catalina_user}",
        require => [File["chmod -R tomcat:tomcat apache-tomcat"],User["${catalina_user}"]],
    }

    # sysconf file - java options
    file { "/etc/sysconfig/tomcatd":
        ensure  => file,
        owner   => "root",
        group   => "root",
        mode    => "0755",
        content => template("tomcat6/tomcatd-sysconf.erb"),
        notify  => Service["tomcatd"],
        require => File["${catalina_home}"],
    }
    
    # run directory
    file { "/var/run/tomcat":
        ensure  => directory,
        owner   => "${catalina_user}",
        group   => "${catalina_user}",
        mode    => 0644,
        require => User["${catalina_user}"],
    }

    # init script
    file { "/etc/init.d/tomcatd":
        ensure  => file,
        owner   => "root",
        group   => "root",
        mode    => "0755",
        content => template("tomcat6/tomcatd-init-script.erb"),
        notify  => Service["tomcatd"],
        require => [User["${catalina_user}"],File["${catalina_home}","/etc/sysconfig/tomcatd","/var/run/tomcat"]],
    }

    service { "tomcatd":
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => [File["/etc/init.d/tomcatd"],Package["java"]],
    }

    # Configuration
    file { 
        "${catalina_home}/conf/server.xml":
            ensure  => file,
            owner   => "${catalina_user}",
            group   => "${catalina_user}",
            mode    => 0600,
            notify  => Service["tomcatd"],
            content => template("tomcat6/conf/server.xml.erb"),
            require => [User["${catalina_user}"],File["${catalina_home}","${engine_dir}"]];
        "${catalina_home}/conf/context.xml":
            ensure  => file,
            owner   => "${catalina_user}",
            group   => "${catalina_user}",
            mode    => 0600,
            notify  => Service["tomcatd"],
            source  => "puppet:///modules/tomcat6/conf/context.xml",
            require => [User["${catalina_user}"],File["${catalina_home}"]];
        "${catalina_home}/conf/tomcat-users.xml":
            ensure  => file,
            owner   => "${catalina_user}",
            group   => "${catalina_user}",
            mode    => 0600,
            notify  => Service["tomcatd"],
            source  => "puppet:///modules/tomcat6/conf/tomcat-users.xml",
            require => [User["${catalina_user}"],File["${catalina_home}"]];
    }

    file { "${engine_dir}":
        ensure  => directory,
        owner   => "${catalina_user}",
        group   => "${catalina_user}",
        mode    => 0644,
        require => [User["${catalina_user}"],File["${catalina_home}"]], 
    }

    # Extra lib
    file { "${catalina_home}/lib/postgresql-9.1-902.jdbc4.jar":
        ensure  => file,
        owner   => "${catalina_user}",
        group   => "${catalina_user}",
        mode    => 0600,
        notify  => Service["tomcatd"],
        source  => "puppet:///modules/tomcat6/lib/postgresql-9.1-902.jdbc4.jar",
        require => [User["${catalina_user}"],File["${catalina_home}"]],
    }
}
