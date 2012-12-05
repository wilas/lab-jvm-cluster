# postgresql9-tomcat6-apache2 cluster:

Provisioning, deployment and clustering of Java Web Applications using puppet.

## VM description:
 - OS: Scientific linux 6
 - apache vm: canoe01.farm
 - tomcat vm: marlin01.farm, marlin02.farm
 - postgresql vm: mammoth.farm

## Howto

 - create SL64_box using [veewee-SL64-box](https://github.com/wilas/veewee-SL64-box)
 - copy ssh_keys from [ssh-gerwazy](https://github.com/wilas/ssh-gerwazy)
 - Run on your host machine (desktop): `echo '77.77.77.171 canoe_red.qq canoe_blue.qq bering.sea' >> /etc/hosts`

```
    vagrant up
    ssh root@77.77.77.150 #mammoth
    ssh root@77.77.77.161 #marlin01
    ssh root@77.77.77.162 #marlin02
    ssh root@77.77.77.171 #canoe01
    vagrant destroy
```

## Urls to play:

Check on at least 2 webbrowsers to see how load_balancer work or use apache benchmark.

Try stop one tomcatd service and check again.

 - apache (load_balancer):
    - http://bering.sea                    # welcome_jsp
    - http://bering.sea/lighthouse         # welcome_servlet
    - http://bering.sea/ship_red           # java_ship_app
    - http://bering.sea/ship_blue          # java_ship_app
    - http://bering.sea/server-status
    - http://bering.sea/balancer-manager
    - http://canoe_red.qq                  # example apache v_host
    - http://canoe_blue.qq                 # example apache v_host
    - http://localhost:7081
 - tomcat:
    - http://localhost:6881                # welcome_jsp on merlin01
    - http://localhost:6881/ship_red       # java_ship_app on merlin01
    - http://localhost:6882                # welcome_jsp on merlin02
    - http://localhost:6882/ship_red       # java_ship_app on merlin02

## App Deployment:

### Deployment procedure:

Deployment are automated and made by puppet tomcat6::virt_host definition. 

Puppet detect if $appSource/context or $appSource/wars directory were changed and apply those modyfications to tomcat server.

Procedure step by step (after change detection):
 - stop tomcatd service
 - clean old appBase
 - deploy new app (new_wars in warBase)
 - deploy new contex
 - start tomcatd service

Example virt_host definition:

```ruby

    tomcat6::virt_host { "localhost":
        appBase   => "my_webapps",
        warBase   => "my_wars",
        appSource => "/vagrant/samples/java_app",
    }
```

### Deployment play:

wars change:

```
    touch samples/java_app/wars/empty.war
    vagrant provision
    rm samples/java_app/wars/empty.war
    vagrant provision
```

contex change:

```
    mv samples/java_app/context/lighthouse.xml .
    vagrant provision   #then look into bering.sea/lighthouse
    mv lighthouse.xml samples/java_app/context/
    vagrant provision   #then look into bering.sea/lighthouse
```

src change:

```
    Import each app to eclipse
    modify sth in source code
    export war to proper place
    deploy app (vagrant prosiosion)
```

## Webapps descriptions:

 - java_app (src: samples/java_app/src/):
   - welcome_jsp: simple index.jsp file
   - welcome_servlet: simple servlet with implemented doGet(req,resp) method
   - java_ship_app: simple app with session, doPost(req,resp) method and DB connection


## Tests:
 - apache benchmark (yum install httpd-tools): ab -n 10000 -c 5 http://bering.sea/ship_red/winemenu
 - jmeter

## Bibliography:

### Apache:
 - !!! mod_proxy_ajp: http://httpd.apache.org/docs/2.2/mod/mod_proxy_ajp.html
 - jmeter: http://jmeter.apache.org/usermanual/build-web-test-plan.html
 - apache benchmark: http://www.cyberciti.biz/tips/howto-performance-benchmarks-a-web-server.html
 - load_balancer example: http://www.richardnichols.net/2010/08/5-minute-guide-clustering-apache-tomcat/
 - load_balancer example: http://datum-bits.blogspot.co.uk/2011/05/setting-up-apache-and-tomcat-with.html

### Tomcat:
 - hpage: http://tomcat.apache.org/
 - !!! context: http://tomcat.apache.org/tomcat-6.0-doc/appdev/deployment.html#Tomcat_Context_Descriptor
 - !!! virtual-hosting: http://tomcat.apache.org/tomcat-6.0-doc/virtual-hosting-howto.html
 - realn howto: http://tomcat.apache.org/tomcat-6.0-doc/realm-howto.html
 - jndi datasource: http://tomcat.apache.org/tomcat-6.0-doc/jndi-datasource-examples-howto.html#PostgreSQL
 - postgresql jdbc driver: http://jdbc.postgresql.org/download.html
 - !!! resource description: https://confluence.atlassian.com/display/DOC/Configuring+a+PostgreSQL+Datasource+in+Apache+Tomcat
 - install: http://www.server-world.info/en/note?os=CentOS_6&p=tomcat7
 - install: http://www.mulesoft.com/tomcat-linux
 - architecture: http://www.akadia.com/download/soug/tomcat/html/tomcat_apache.html#Java%20Servlets
 - deploying each war using puppet: http://www.tomcatexpert.com/blog/2010/04/29/deploying-tomcat-applications-puppet

### Postgresql:
 - postgresql 9.1 full documentation: http://www.postgresql.org/docs/9.1/static/index.html
 - postgresql replication: http://www.debian-administration.org/article/How_to_setup_Postgresql_9.1_Streaming_Replication_Debian_Squeeze
 - (bonus) postgresql performance: http://www.postgresql.org/docs/current/static/kernel-resources.html


## TODO:

### Basic:
 - virt_host in tomcat + augeas
 - ssl in apache
 - memcached: http://www.cyberciti.biz/faq/howto-install-memcached-under-rhel-fedora-centos/

### Other: 
 - apache HA, e.g. using heartbeat - [heartbeat-cluster](https://github.com/wilas/heartbeat-cluster)
 - postgresql9 replication

## Copyright and license

Copyright 2012, Kamil Wilas (wilas.pl)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this work except in compliance with the License.
You may obtain a copy of the License in the LICENSE file, or at:

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

