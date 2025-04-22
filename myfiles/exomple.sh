ansible-galaxy init webserver

#tasks/main.yml
---
# tasks file for apache
- name: update apt cache
  become: true
  apt:
    update_cache: no
- name: install appache
  become: true
  apt:
    name: apache2
    state: present
- name: copy apache config file
  template:
    src: apache2.conf.j2
    dest: /etc/apache2/apache2.conf
- name: crate index.html
  template:
    src: index.html.j2
    dest: "{{ document_root}}/index.html"
- name: enable and start service
  systemd:
    name: apache2
    enabled: yes
    state: started

#vars/main.yml
---
document_root: /var/www/html
user_name: world
# templates/index.html.j2
<!DOCTYPE html>
<html>
    <head>
        <title>Welcome to My Website!</title>
    </head>
    <body>
        <h1> Hello , {{ user_name }}! </h1>
    </body>
</html>
 
#templates/apache2.conf.j2
ServerName {{ ansible_hostname }}
Listen 80

LoadModule mpm_prefork_module /user/lib/apache2/modules/mod_mpm_prefork.so

<IfModule mpm_prefork_module>
    StartServers        5
    MinSpareServers     5
    MaxSpareServers     10
    MaxClients          150
    MaxRequestsPerChild   0
</IfModule>

document_root {{ document_root }}

<Directory {{ document_root }}>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>

ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined

#apache-install.yml
---
- hosts: db
  become: true
  roles:
    - apache
#
devops@master:/etc/ansible$ sudo cat env 
[app]
10.0.2.7 ansible_user=devops ansible_ssh_pass=1992
10.0.2.8 ansible_user=devops ansible_ssh_pass=1992
[db]
10.0.2.9 ansible_user=devops ansible_ssh_pass=1992


#commande 
sudo ansible-playbook -i env apache-install.yml --become --become-user root --ask-become-pass



