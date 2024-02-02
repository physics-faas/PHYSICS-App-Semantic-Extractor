/**
 * This pipeline Kaniko for Semantic Extractor
 */

def label = "kaniko-${UUID.randomUUID().toString()}"

properties(
  [
  parameters(
     [
     string(defaultValue: 'semantic-extractor:latest', name: 'dockerimagename'),
     booleanParam(name: 'deploy_dev', defaultValue: false),
     string(name: 'projectname', defaultValue: 'wp3')
     ]
    )
   ]
  )

podTemplate(label: label, namespace: 'devops', yaml: """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:v1.8.1-debug
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo Welcome ; sleep 100; done"]
    resources:
      requests:
        cpu: 100m
        memory: 256Mi
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  volumes:
  - name: jenkins-docker-cfg
    secret:
      secretName: jenkinssecretregistry
      items:
      - key: .dockerconfigjson
        path: config.json
"""
  ) {
/* Slack notify integration */

  def notifySlack = { String buildStatus ->
    // Build status of null means success.
    buildStatus = buildStatus ?: 'SUCCESS'

    def color

    if (buildStatus == 'STARTED') {
      color = '#D4DADF'
    } else if (buildStatus == 'SUCCESS') {
      color = '#BDFFC3'
    } else if (buildStatus == 'UNSTABLE') {
      color = '#FFFE89'
    } else {
      color = '#FF9FA1'
    }

    def msg = "${buildStatus}: `${env.JOB_NAME}` #${env.BUILD_NUMBER}:\n${env.BUILD_URL}"

    slackSend(color: color, message: msg)
  }

  node(label) {
    def project = 'wp3'
    def dockerPhysics = 'registry.apps.ocphub.physics-faas.eu'
    def registryPhysics = 'https://registry.apps.ocphub.physics-faas.eu'
    checkout scm
    try {
      notifySlack('STARTED')
      stage('Build and push Docker Image') {
        container('kaniko') {
          sh """
               /kaniko/executor -f `pwd`/Dockerfile -c `pwd` --insecure --skip-tls-verify \
               --cache=false \
               --destination=${dockerPhysics}/${project}/${dockerimagename} \
               --force 
                
         """
        }
      }
   }catch (e) {
      println "Failed to deploy - ${currentBuild.fullDisplayName}"
      notifySlack('UNSTABLE')
      echo 'Exception occurred: ' + e.toString()
      currentBuild.result = 'FAILURE'
    }
   finally {
      // Success or failure, always send notifications
      notifySlack(currentBuild.result)
   }

   stage ('Start deploy pipeline') {
     build job: 'Semantic_Extractor-DEPLOY', parameters: [string(name: 'projectname',  value: "${projectname}")]
    }
 }
}