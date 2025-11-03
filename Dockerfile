# Stage 1: Build
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -q -e -DskipTests clean package

# Stage 2: Runtime 
FROM eclipse-temurin:17-jre
RUN groupadd -g 10001 appgroup \
    && useradd -r -u 10001 -g appgroup appuser
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
ENV DB_HOST=localhost \
    DB_PORT=3306 \
    DB_NAME=sprint4 \
    DB_USER=root \
    DB_PASSWORD=password
USER appuser
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]

