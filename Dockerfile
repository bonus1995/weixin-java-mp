FROM openjdk:8-jdk-alpine
VOLUME /tmp
COPY target/weixin-java-mp-demo-springboot-1.0.0-SNAPSHOT.jar /app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
