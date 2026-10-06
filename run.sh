docker rm -f jenkins

docker run -d \
  --name jenkins \
  -p 8888:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins-with-docker:lts-jdk25