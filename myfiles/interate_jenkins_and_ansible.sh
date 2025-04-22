https://app.pluralsight.com/ilx/video-courses/1534aca4-fdbe-442f-82e5-9842307b5a93/6442a0c1-7e2e-4851-ac9f-a7ae98b3ff42/c611af14-1842-4587-8881-be308fa5a53f

jenkins URL: http://10.0.2.15:8080/ (admin[1992])

projet URL : https://github.com/imedbouajila/Media99

# /etc/sudoers
%sudo	ALL=(ALL:ALL) ALL
jenkins ALL=(ALL:ALL) NOPASSWD:ALL
devops  ALL=(ALL:ALL) ALL

# config ansible in jenkins 
1- installer le plugin ssh et ansible 
2- creer un credentiel : ssh : username + id_rsa
3-freejob pieline :ssh -tt -l devops 10.0.2.7 ls -al

#demo.yml
---
- hosts: all
  become: true
  vars_files: secret.yml
  tasks:
    - name: apt-update
      apt:
        update_cache: yes
      ignore_errors: yes     
    - name: install docker
      apt:
        name: docker.io
        state: present
    - name: creat new folder
      become_user: devops
      file:
        path: /home/devops/target
        state: directory
    - name: copy the source code to hosts
      copy: src=./{{ item }} dest=/home/devops/target/
      become_user: devops
      with_items:
        - app
        - migrations
        - flask.py
        - config.py
        - boot.sh
        - data-dev.sqlite
        - Dockerfile
        - requirements
    - name: set the executable permission
      command: chmod +x /home/devops/target/boot.sh
    - name: build docker image
      command: chdir=/home/devops/target/ docker build . -t mediaapp
    - name: run docker container
      command: chdir=/home/devops/target/ docker run -itd -p 8085:5000 mediaapp

##vault
evops@master:/etc/ansible$ sudo ansible-vault create passwd.yml
New Vault password: 
Confirm New Vault password: 
devops@master:/etc/ansible$ sudo cat passwd.yml
$ANSIBLE_VAULT;1.1;AES256
37316333333830636433303332316461656264346237393835653763346131626439336265333864
3937396333313337396565376135306634323039646363640a383933646662653738643730306638
33356231346438613234303661353733386636656336356262376430306130663233373633383437
3034633666373363360a343366643138636264303564643264336264373166643061383138636662
6233
devops@master:/etc/ansible$ sudo ansible-vault view passwd.yml 
Vault password: 
devops: 1992
devops@master:/etc/ansible$ 
devops@master:/etc/ansible$ sudo ansible-vault edit passwd.yml 
Vault password: 
#changer le mdp vault
devops@master:/etc/ansible$ sudo ansible-vault rekey passwd.yml 
Vault password:

devops@master:/etc/ansible$ sudo cat vault.yml
---
- hosts: all
  become: true 
  vars_files: passwd.yml
  tasks:
    - ansible.builtin.debug: 
      msg: the value of the variable from passwd.yml file is {{ devops }}

# command
sudo ansible-playbook --ask-vault-pass vault.yml --become --become-user root --ask-become-pass

# ansible secret.yml for vault branch is secret123
ibouajila@LAPTOP-N4RH7QAL:/mnt/c/externe/Devops/ansible/ansible-main/Media99$ ansible-vault view secret.yml 
Vault password: 
env_vars:
        FLASK_APP: flasky.py
        FLASK_DEBUG: 1
SECRET_KEY: demovalue  # la clé utilsée dans le playbook 

# playbook 
---
- hosts: all
  become: yes
  vars_files: secret.yml
  tasks:
   - name: apt-update
     apt:
      update_cache: yes
     ignore_errors: true   
   - name: Install Docker
     apt:
      name: docker
      state: present
   - name: Create new directory
     become_user: devops
     file:
      path: /home/devops/target
      state: directory
   - name: Copy the source code to hosts
     copy: src=./{{ item }} dest=/home/devops/target/
     become_user: devops
     with_items:
        - app
        - migrations
        - flasky.py
        - config.py
        - boot.sh
        - data-dev.sqlite
        - Dockerfile
        - requirements
   - name: Set the executable permission
     command: chmod +x /home/devops/target/boot.sh  
   - name: Build Docker Image
     command: chdir=/home/devops/target/ docker build . -t mediaapp
   - name: Run Docker Container
     command: chdir=/home/devops/target/ docker run -itd -e SECRET_KEY="{{ SECRET_KEY }}" -p 8085:5000 mediaapp
#
1 - creer un credentiel type secret text (pwd : secret123)
2- pipline syntaxe ; declarer le playbook 
#snipette de code 
ansiblePlaybook become: true, credentialsId: 'UbuntuID1', installation: 'A1', inventory: '/etc/ansible/env', playbook: './app_playbook.yml', vaultCredentialsId: 'vaultID1', vaultTmpPath: ''
#jenkins file
pipeline{
	agent{label 'master'}
        environment {
          LANG = 'en_US.UTF-8'
          LC_ALL = 'en_US.UTF-8'
        }
	stages{
		stage('Checkout'){
			steps{
				git branch: 'vault', url: 'https://github.com/imedbouajila/Media99.git'
			}
		}
    		stage('Setup'){
      			steps{
				sh 'chmod +x install.sh'
        			sh './install.sh'
      			}
    		}
    		stage('Test'){
      			steps{
				 sh '''#!/bin/bash
				     echo HELLO
				     '''
               			}
   		}
         stage('Ansible Deploy') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'sudo_pass', variable: 'BECOME_PASS')
                    ]) {
                        ansiblePlaybook(
                            become: true,
                            credentialsId: 'UbuntuID1',
                            installation: 'A1',
                            inventory: '/etc/ansible/env',
                            playbook: './app_playbook.yml',
                            vaultCredentialsId: 'vaultID1',
                            vaultTmpPath: '',
                            extraVars: [
                                ansible_become_pass: "${BECOME_PASS}"
                            ]
                        )
                    }
                }
            }
        }
    }
}

#
