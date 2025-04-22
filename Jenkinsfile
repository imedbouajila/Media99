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
		stage('invoke playbook'){
      			steps{
				// ansiblePlaybook credentialsId: 'UbuntuID1', disableHostKeyChecking: true, inventory: '/etc/ansible/env', installation: 'A1', playbook: './app_playbook.yml', vaultCredentialsId: 'VaultID1' , vaultTmpPath: './secret.yml'               			
   	ansiblePlaybook become: true, credentialsId: 'UbuntuID1', installation: 'A1', inventory: '/etc/ansible/env', playbook: './app_playbook.yml', vaultCredentialsId: 'vaultID1', vaultTmpPath: ''
           	}
	}
   }
}
