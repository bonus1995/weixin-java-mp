node('haimaxy-jnlp') {
    stage('准备') {
        echo "1.Prepare Stage"
        checkout scm
        script {
            build_tag = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
            if (env.BRANCH_NAME != 'master') {
                build_tag = "${env.BRANCH_NAME}-${build_tag}"
            }
        }
    }
    stage('代码编译') {
      echo "2.mvn Stage"
      docker.image('maven:3.3.3').inside {
      sh "mvn clean install -DskipTests"
    }
    }
    stage('构建镜像') {
        echo "3.Build Docker Image Stage"
        sh "docker build -t harbor-k8s.iwgame.com/containers/weixin-java-mp-demo:${build_tag} ."
    }
    stage('推送镜像') {
        echo "4.Push Docker Image Stage"
        withCredentials([usernamePassword(credentialsId: 'harbor', passwordVariable: 'harborPassword', usernameVariable: 'harborUser')]) {
            sh "docker login harbor-k8s.iwgame.com -u ${harborUser} -p ${harborPassword}"
			sh "docker push harbor-k8s.iwgame.com/containers/weixin-java-mp-demo:${build_tag}"
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

