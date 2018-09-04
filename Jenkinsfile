node{
    stage('Initialize') {
        echo 'Initializing...'
        def node = tool name: 'Node-7.4.0', type: 'jenkins.plugins.nodejs.tools.NodeJSInstallation'
        env.PATH = "${node}/bin:${env.PATH}"
	echo "${node}"
	echo env.PATH
    }

    stage('Checkout') {
        echo 'Getting source code...'
        checkout scm
    }

    stage('Build') {
        echo 'Building dependencies...'
        sh 'npm i'
    }

    stage('Test') {
        echo 'Testing...'
        sh 'npm test'
    }

    	stage('Docker Build and Publish') {
		buildAndPush('basivireddy', "${env.JOB_NAME}", 'v1.0');
    }
	
	stage('Deploy to OpenShift') {
		deployOpenShift('basivireddy', "${env.JOB_NAME}", 'v1.0', "${env.BUILD_NUMBER}", "piab-demo");
    }
	
	
}

def buildAndPush(registryID, imageName, version){
    def app
    try {
	    app = docker.build("${registryID}/${imageName}")
		docker.withRegistry('https://registry.hub.docker.com', 'docker-credentials') {
		    app.push("${version}.${env.BUILD_NUMBER}")
		}
	} catch (error){
		sh 'echo "Not able to build and push docker image ${error}"'
	}
}

def deployOpenShift(registryID, imageName, version, buildNo, namespace){

	env.PATH = "/var/lib/jenkins/tools/:${env.PATH}"

    sh "oc login $URL_OS_TEST --token=$TOKEN_OS_TEST --insecure-skip-tls-verify"
	
	output = sh(script: "oc tag --source=docker ${registryID}/${imageName}:${version}.${buildNo} ${imageName}:${version}.${buildNo} -n ${namespace}", returnStdout: true)
	println output
	
	sh "oc import-image ${imageName}:${version}.${buildNo} --insecure -n ${namespace} || true"
	
	try {
		output = sh(script: "oc new-app --name ${imageName}-${version} --image-stream=${namespace}/${imageName}:${version}.${buildNo} -n ${namespace}", returnStdout: true)
		println output
		
		output = sh(script: "oc expose service/${imageName}-${version} --path=/wso2apim-demo --hostname=${imageName}-${version}-test.magellancloud.com -n ${namespace}", returnStdout: true)
		println output
	} catch (error){
		output = sh(script: "oc deploy ${imageName}-${version} --latest -n ${namespace} || true", returnStdout: true)
		println output
	}
}
