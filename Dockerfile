# Build and run Spring Boot app as a fat JAR
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app
# Copy the built jar from the Maven target directory
# Asegúrate de ejecutar `mvn clean package` antes del build de la imagen
COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/app.jar"]
