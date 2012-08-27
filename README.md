# postgresql9-tomcat6-apache2 cluster:
Provisioning, deployment and clustering of Java Web Applications using puppet.

## VM description:
 - apache vm: canoe01
 - tomcat vm: marlin01, marlin02
 - postgresql vm: mammoth

## Additional configuration (on host machine):
 - Add into /etc/hosts on your host machine: 77.77.77.171 canoe.me canoe.to marlinschool.me

## Step by step:
 - create SL64_box
 - additional configuration
 - vagrant up
 - browse urls
 - vagrant destroy

## Urls:
 - apache: marlinschool.me (localhost:7081)
 - tomcat: localhost:6881, localhost:6882
 - context: ...

## Webapps descriptions (url_to_scr):
 - welcome_servlet: ...
 - simple_db: ...
 - servlet_me: ...
 - simple_dynamo: ...

## Tests:
 - apache benchmark (yum install httpd-tools): ab -n 10000 -c 5 http://marlinschool.me/testme/SimpleSearch
 - jmeter: ...

## Bibliography:

## TODO:
 - virt_host in tomcat + augeas
 - memcached
 - ssl in apache

## Other: 
- heartbeat (+canoe02)
- postgresql9 replication
