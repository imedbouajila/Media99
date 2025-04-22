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
