# Build and run Spring Boot app as a fat JAR
# ==========================
# BUILD STAGE
# ==========================
FROM eclipse-temurin:17-jdk-alpine as build

# Install Maven
RUN apk add --no-cache maven

# Set working directory
WORKDIR /app

# Copy Maven project files
COPY pom.xml .
COPY src ./src

# Build the JAR file
RUN mvn clean package -DskipTests

# ==========================
# RUNTIME STAGE
# ==========================
FROM eclipse-temurin:17-jdk-alpine

# Create app directory
WORKDIR /app

# Copy built JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose Spring Boot default port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
