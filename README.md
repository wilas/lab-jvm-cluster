# postgresql9-tomcat6-apache2 cluster:
Provisioning, deployment and clustering of Java Web Applications using puppet.

## VM description:
 - OS: Scientific linux 6
 - apache vm: canoe01.farm
 - tomcat vm: marlin01.farm, marlin02.farm
 - postgresql vm: mammoth.farm

## Additional configuration (on host machine):
 - Add into /etc/hosts on your host machine: 77.77.77.171 canoe_red.qq canoe_blue.qq bering.sea

## Step by step:
 - create SL64_box
 - additional configuration
 - vagrant up
 - browse urls
 - vagrant destroy

## Urls:
 - apache: bering.sea (localhost:7081)
 - tomcat: localhost:6881, localhost:6882
 - context: /ship_red /ship_blue /lighthouse

## Webapps descriptions (url_to_scr):
 - java_ship_app: ...
 - welcome_jsp: ...
 - welcome_servlet: ...

## Tests:
 - apache benchmark (yum install httpd-tools): ab -n 10000 -c 5 http://bering.sea/ship_red/winemenu
 - jmeter: link

## Bibliography:

## TODO:
 - virt_host in tomcat + augeas
 - memcached
 - ssl in apache

## Other: 
- [heartbeat](https://github.com/wilas/heartbeat-cluster)
- postgresql9 replication

## Copyright and license

Copyright 2012, the jvm-cluster authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this work except in compliance with the License.
You may obtain a copy of the License in the LICENSE file, or at:

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

