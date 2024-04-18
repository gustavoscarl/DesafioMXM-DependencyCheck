# Use an official OpenJDK image as a base
FROM openjdk:11

# Set the working directory
WORKDIR /app

# Install Dependency-Check
ADD https://github.com/jeremylong/DependencyCheck/releases/download/v9.1.0/dependency-check-9.1.0-release.zip /app/
RUN apt-get update && \
    apt-get install -y unzip && \
    unzip dependency-check-9.1.0-release.zip && \
    rm dependency-check-9.1.0-release.zip && \
    mv dependency-check /opt/dependency-check

# Define the entry point
ENTRYPOINT ["/opt/dependency-check/bin/dependency-check.sh"]
