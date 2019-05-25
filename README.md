# jnlp-slave-dotnet
 
## Usage
 
See [jenkins/jnlp-slave](https://hub.docker.com/r/jenkins/jnlp-slave/)

dotnet tool example:
``` Groovy
stage('build') {
    steps {
        sh 'dotnet tool install -g dotnet-reportgenerator-globaltool'
        sh 'reportgenerator -help'
    }
}
```

cake build example:
``` Groovy
stage('build') {
    steps {
        sh 'cake ./build.cake'
    }
}
```
 
## Version

Integration feature: -

+ dotnet sdk v2.2.204
+ cake build v0.33.0

to

Base image: `jenkins/jnlp-slave:3.27-1`
