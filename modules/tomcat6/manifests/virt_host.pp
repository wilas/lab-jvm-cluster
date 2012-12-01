
# http://tomcat.apache.org/tomcat-6.0-doc/appdev/deployment.html#Tomcat_Context_Descriptor
# http://tomcat.apache.org/tomcat-6.0-doc/virtual-hosting-howto.html
# other approach: deploy each war...

define tomcat6::virt_host($appBase,$warBase,$appSource) {

    include tomcat6

    #notice("Mirror, mirror, tell me true: ${tomcat6::catalina_home}")
    #TODO !!!:
    #add host entry to server.xml ~> augeas ??
    #Define the default virtual host
    #<Host name="$host_name" appBase="$appBase"/>

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
        path => "/bin:/sbin:/usr/bin:/usr/sbin",
        command => "rm -rf ${tomcat6::catalina_home}/${appBase}/*",
        subscribe => Exec["tomcat stop ${name}"],
        notify      => Service["tomcatd"],
        refreshonly => true,
    }

    exec {"tomcat stop ${name}":
        path => "/bin:/sbin:/usr/bin:/usr/sbin",
        command => "/etc/init.d/tomcatd stop",
        subscribe => File["${warBase}","${context}"],
        refreshonly => true,
    }

#http://blog.moertel.com/articles/2007/11/15/a-couple-of-tips-for-writing-puppet-manifests
#capture the passed-on prerequisites?
    file { "${appBase}":
        path => "${tomcat6::catalina_home}/${appBase}",
        ensure => directory,
        owner => "${tomcat6::catalina_user}",
        group => "${tomcat6::catalina_user}", 
        require => File["${tomcat6::engine_dir}"],
    }

#deploy new app
    file { "${warBase}":
        path => "${tomcat6::catalina_home}/${warBase}",
        ensure => present,
        owner => "${tomcat6::catalina_user}",
        group => "${tomcat6::catalina_user}",
        source => "${appSource}/wars",
        recurse => true,
        purge => true,
        require => File["${appBase}"],
    }
    
    file { "${context}":
        ensure => present,
        owner => "${tomcat6::catalina_user}",
        group => "${tomcat6::catalina_user}",
        source => "${appSource}/context",
        recurse => true,
        purge => true,
        require => File["${warBase}"],
    }
}
