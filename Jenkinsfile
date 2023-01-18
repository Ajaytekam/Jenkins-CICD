def COLOR_MAP = [
'SUCCESS': 'good',
'FAILURE': 'danger'
]

pipeline {
    agent any

    environment {
        registryCredential = 'ecr:us-east-1:aws-creds'
        appRegistry = "897003471175.dkr.ecr.us-east-1.amazonaws.com/vprofileappimg"   
        vprofileRegistry = "https://897003471175.dkr.ecr.us-east-1.amazonaws.com/vprofileappimg"   
        cluster = "vprofile"
        service = "vprofileappsvc"
    }

    tools {
        maven "MAVEN3"
        jdk "OpenJDK8"
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Ajaytekam/testrepo01.git'
            }
        }

        stage('Unit Testing') {
            steps{
                sh 'mvn test'
            }
        }

        stage('Integration Testing') {
            steps{
                sh 'mvn verify -DskipUnitTests'  
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean install -DskipTests'
            }

            post {
                success {
                    echo 'Now archiving it...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }

        stage('Checkstyle Analysis') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }

        stage('SonarQube Code Analysis') {

            environment {
                scannerHome = tool 'Sonar4.8'
            }

            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonar-api') {
                        //sh 'mvn clean package sonar:sonar'
                        sh '''export JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64;
                        ${scannerHome}/bin/sonar-scanner -X \
                        -Dsonar.projectKey=vprofile \
                        -Dsonar.projectName=vprofile \
                        -Dsonar.projectVersion=1.0 \
                        -Dsonar.sources=src/ \
                        -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                        -Dsonar.junit.reportsPath=target/surefire-reports/ \
                        -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml
                       '''
                    }
                }
            }
        }

        stage('SonarQube Quality Gate Status') {
            steps{
                timeout(time: 1, unit: 'HOURS') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    //waitForQualityGate abortPipeline: true
                    waitForQualityGate abortPipeline: true, credentialsId: 'sonar-api'  
                }
            }
        }

        stage('Nexus Artifact uploader') {
            steps {
                script {

                    /* nexusArtifactUploader artifacts: [ */
                    /*     [ */
                    /*       artifactId: 'vprofile', */ 
                    /*       classifier: '', */ 
                    /*       file: "target/vprofile-v2.war", */ 
                    /*       type: 'war' */
                    /*     ] */
                    /*   ], */ 
                    /*   credentialsId: 'nexus-creds', */ 
                    /*   groupId: 'com.visualpathit', */ 
                    /*   nexusUrl: '172.31.40.40:8081', */ 
                    /*   nexusVersion: 'nexus3', */ 
                    /*   protocol: 'http', */ 
                    /*   repository: 'new-repo-release', */ 
                    /*   version: "v2" */

                    def version = sh script: 'mvn help:evaluate -Dexpression=project.version -q -DforceStdout', returnStdout: true
                    def artifactId = sh script: 'mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout', returnStdout: true
                    def packaging = sh script: 'mvn help:evaluate -Dexpression=project.packaging -q -DforceStdout', returnStdout: true
                    def groupId = sh script: 'mvn help:evaluate -Dexpression=project.groupId -q -DforceStdout', returnStdout: true

                    nexusArtifactUploader artifacts: [
                        [
                            artifactId: "${artifactId}", 
                            classifier: '', 
                            file: "target/${artifactId}-${version}.war",
                            type: "${packaging}"
                        ]
                    ], 
                    credentialsId: 'nexus-creds', 
                    groupId: "${groupId}",
                    nexusUrl: '172.31.40.40:8081', 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: 'new-repo-release', 
                    version: "${version}"
                }
            }
        }
        
        stage('Build App Image') {
            steps {
                script {
                    dockerImage = docker.build(appRegistry + ":$BUILD_NUMBER", ".")
                }
            }
        }

        stage('Upload app image') {
            steps {
                script {
                    docker.withRegistry( vprofileRegistry, registryCredential ) {
                        dockerImage.push("$BUILD_NUMBER")    
                        dockerImage.push("latest")   
                    }
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    sh 'aws ecs update-service --cluster ${cluster} --service ${service} --force-new-deployment'
                }
            }
        }
        
    }

    post {
        always {
            echo 'Slack Notification.'
            slackSend channel: '#test01',
            color: COLOR_MAP[currentBuild.currentResult],
            message: "*${currentBuild.currentResult}* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"                          }
    }
}
