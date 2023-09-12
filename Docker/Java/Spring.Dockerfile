# Use the official maven/Java 11 base image
FROM maven:3.8.1-openjdk-11-slim as build

WORKDIR /app

COPY src /app/src
COPY pom.xml /app

RUN mvn -f /app/pom.xml clean package

FROM openjdk:11-jre-slim

WORKDIR /app

COPY --from=build /app/target/my-app.jar /app

EXPOSE 8080

CMD ["java", "-jar", "my-app.jar"]
