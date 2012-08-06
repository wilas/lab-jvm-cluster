#
#I recommend use the latest official Apache-Tomcat binary release (the best way to avoid errors and confusion).
#The official Tomcat page is your friend in this regard http://tomcat.apache.org/
#Tomcat 6.0.35 is the current version of this writing. 
#

# puppet 2.7 update:
# Autorequires: If Puppet is managing the user or group that owns a file, the file resource will autorequire them. 
# If Puppet is managing any parent directories of a file, the file resource will autorequire them.

#Manage firewall in node definition

class tomcat6 {

    $version = "6.0.35"
    $jvm_home = "/usr/lib/jvm/java/"
    $catalina_home = "/opt/tomcat"
    $catalina_user = "tomcat"
    #$java_opts = ""
    
    $engine_dir = "${catalina_home}/conf/Catalina"
    #$virthost_list = [] -> create server.xml from template

    #future: install openjdk 7
    package { "java":
        name   => ["java-1.6.0-openjdk", "java-1.6.0-openjdk-devel"],
        ensure => installed,
    }

    #useradd -s /sbin/nologin -g tomcat -d /path/to/tomcat tomcat
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
        require => File["tomcat package"],
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

    #sysconf file
    file { "/etc/sysconfig/tomcatd":
        ensure  => file,
        owner   => "root",
        group   => "root",
        mode    => "0755",
        content => template("tomcat6/tomcatd-sysconf.erb"),
        notify  => Service["tomcatd"],
        require => File["${catalina_home}"],
    }
    
    #run directory
    file { "/var/run/tomcat":
        ensure  => directory,
        owner   => "${catalina_user}",
        group   => "${catalina_user}",
        mode    => 0644,
        require => User["${catalina_user}"],
    }

    #init script
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
    file { "${catalina_home}/conf/server.xml":
        ensure  => file,
        owner   => "${catalina_user}",
        group   => "${catalina_user}",
        mode    => 0600,
        notify  => Service["tomcatd"],
        source  => "puppet:///modules/tomcat6/conf/server.xml",
        require => [User["${catalina_user}"],File["${catalina_home}","${engine_dir}"],Virt_host["localhost"]],
    }
    
    file { "${catalina_home}/conf/context.xml":
        ensure  => file,
        owner   => "${catalina_user}",
        group   => "${catalina_user}",
        mode    => 0600,
        notify  => Service["tomcatd"],
        source  => "puppet:///modules/tomcat6/conf/context.xml",
        require => [User["${catalina_user}"],File["${catalina_home}"]],
    }

    file { "${catalina_home}/conf/tomcat-users.xml":
        ensure  => file,
        owner   => "${catalina_user}",
        group   => "${catalina_user}",
        mode    => 0600,
        notify  => Service["tomcatd"],
        source  => "puppet:///modules/tomcat6/conf/tomcat-users.xml",
        require => [User["${catalina_user}"],File["${catalina_home}"]],
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


    #http://tomcat.apache.org/tomcat-6.0-doc/appdev/deployment.html#Tomcat_Context_Descriptor
    #http://tomcat.apache.org/tomcat-6.0-doc/virtual-hosting-howto.html
    #other approach: deploy each war...
    define virt_host($appBase,$warBase,$appSource) {

        #notice("Mirror, mirror, tell me true: ${tomcat6::catalina_home}")
    
        #TODO:
        #add host entry to server.xml ~> augeas ??
        #<Host name="$host_name"    appBase="$appBase"/>

        $host_name = $name
        $context = "${tomcat6::engine_dir}/${host_name}"

        # To do proper deploy:
        #stop tomcat
        #clean old appBase
        #optional: clean work directory ??
        #deploy new app -> new war files
        #deploy new contex
        #start/restart tomcat

        exec {"clean appBase ${name}":
            path 	    => "/bin:/sbin:/usr/bin:/usr/sbin",
            command     => "rm -rf ${tomcat6::catalina_home}/${appBase}/*",
            subscribe   => Exec["tomcat stop ${name}"],
            refreshonly => true,
        }

        exec {"tomcat stop ${name}":
            path 	    => "/bin:/sbin:/usr/bin:/usr/sbin",
            command     => "/etc/init.d/tomcatd stop",
            subscribe   => File["${warBase}","${context}"],
            refreshonly => true,
        }

        #http://blog.moertel.com/articles/2007/11/15/a-couple-of-tips-for-writing-puppet-manifests
        #capture the passed-on prerequisites?
        file { "${appBase}":
            path    =>  "${tomcat6::catalina_home}/${appBase}",
            ensure  => directory,
            owner   => "${tomcat6::catalina_user}",
            group   => "${tomcat6::catalina_user}",
        }

        #deploy new app
        file { "${warBase}":
            path    => "${tomcat6::catalina_home}/${warBase}",
            ensure  => present,
            owner   => "${tomcat6::catalina_user}",
            group   => "${tomcat6::catalina_user}",
            source  => "${appSource}/wars",
            recurse => true,
            purge   => true,
            require => File["${appBase}"],
        }
        
        file { "${context}":
            ensure  => present,
            owner   => "${tomcat6::catalina_user}",
            group   => "${tomcat6::catalina_user}",
            source  => "${appSource}/context",
            recurse => true,
            purge   => true,
            require => File["${warBase}"],
        }
    }

    virt_host { "localhost":
        appBase   => "my_webapps",
        warBase   => "my_wars",
        appSource => '/vagrant/samples/simple_app',
        notify    => Service["tomcatd"],
        require   => File["${engine_dir}"]
    }
   
    #test for multiple virt_host:
    #virt_host { "localhost2":
    #    appBase   => "my_webapps2",
    #    warBase   => "my_wars2",
    #    appSource => '/vagrant/samples/simple_app',
    #    notify    => Service["tomcatd"],
    #    require   => File["${engine_dir}"]
    #}

}
