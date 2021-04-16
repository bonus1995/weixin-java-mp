//镜像仓库
def registry='harbor-k8s.iwgame.com'
//镜像仓库项目名称
def project='containers'


node('haimaxy-jnlp') {
    stage('准备') {
        echo "1.Prepare Stage"
        checkout scm
        script {
            build_tag = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
	    job_name = sh(returnStdout: true, script: 'basename -s .git `git config --get remote.origin.url`').trim()
            if (env.BRANCH_NAME != 'master') {
                build_tag = "${env.BRANCH_NAME}-${build_tag}"
            }
        }
    }
    stage('代码编译') {
      echo "2.mvn Stage"
      docker.image('maven:3.3.3').inside('-v $HOME/.m2:/root/.m2') {
      sh "mvn clean install -DskipTests"
    }
    }
    stage('构建镜像') {
        echo "3.Build Docker Image Stage"
        sh "docker build -t ${registry}/${project}/${job_name}:${build_tag} ."
    }
    stage('推送镜像') {
        echo "4.Push Docker Image Stage"
        withCredentials([usernamePassword(credentialsId: 'harbor', passwordVariable: 'harborPassword', usernameVariable: 'harborUser')]) {
            sh "docker login ${registry} -u ${harborUser} -p ${harborPassword}"
			sh "docker push ${registry}/${project}/${job_name}:${build_tag}"
        }
    }
    stage('部署') {
        echo "5. Deploy Stage"
            sh "sed -i 's/<BUILD_TAG>/${build_tag}/' k8s.yaml"
        if (env.BRANCH_NAME == 'master') {
            input "确认要部署线上环境吗？"
            kubernetesDeploy configs: 'k8s.yaml', kubeconfigId: 'c9333abb-444d-4ff9-bec1-b0ac3135c307'
        } else {
            kubernetesDeploy configs: 'k8s.yaml', kubeconfigId: 'edb797b6-2c27-4ef8-8a49-6d7fa07de49d'
       }
    }
}

