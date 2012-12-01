#
# In that tomcat6 module default virt_host is localhost.
# You can change it manualy by editing server.xml.erb template.
# About virtual-hosting in tomcat6:
# http://tomcat.apache.org/tomcat-6.0-doc/virtual-hosting-howto.html
# http://tomcat.apache.org/tomcat-6.0-doc/appdev/deployment.html#Tomcat_Context_Descriptor
#
# Virt_host definition include also app. deployment.
# My approach - deploy all wars from warBase.
# Read about other approach (deploy each war separately) here:
# http://www.tomcatexpert.com/blog/2010/04/29/deploying-tomcat-applications-puppet
#
# TODO:
# - add virt host entry to server.xml ~> augeas... <Host name="$host_name" appBase="$appBase"/>
#
define tomcat6::virt_host($appBase,$warBase,$appSource,$host_name="localhost") {

    include tomcat6

    # $host_name = $name
    $context = "${tomcat6::engine_dir}/${host_name}"

    # Deployment procedure:
    #   - stop tomcatd service
    #   - clean old appBase
    #   - optional: clean work directory ($CATALINA_BASE/work)
    #   - deploy new app (new_wars in warBase)
    #   - deploy new contex
    #   - start tomcatd service

    # stop tomcat service
    exec {"tomcat stop ${name}":
        path        => "/bin:/sbin:/usr/bin:/usr/sbin",
        command     => "/etc/init.d/tomcatd stop",
        subscribe   => File["${warBase}","${context}"],
        refreshonly => true,
    }

    # clean old appBase
    exec {"clean appBase ${name}":
        path        => "/bin:/sbin:/usr/bin:/usr/sbin",
        command     => "rm -rf ${tomcat6::catalina_home}/${appBase}/*",
        subscribe   => Exec["tomcat stop ${name}"],
        notify      => Service["tomcatd"],
        refreshonly => true,
    }

    # create appBase or check that exist
    file { "${appBase}":
        path    => "${tomcat6::catalina_home}/${appBase}",
        ensure  => directory,
        owner   => "${tomcat6::catalina_user}",
        group   => "${tomcat6::catalina_user}", 
        require => File["${tomcat6::engine_dir}"],
    }

    # deploy new app
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
    
    # deploy context
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
