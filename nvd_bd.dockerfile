FROM openjdk:11-slim

WORKDIR /usr/src/app

ENV DEPENDENCY_CHECK_VERSION 6.5.3
ADD https://github.com/jeremylong/DependencyCheck/releases/download/v${DEPENDENCY_CHECK_VERSION}/dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip /usr/src/app/
RUN apt-get update && \
    apt-get install -y unzip && \
    unzip dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip && \
    rm dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip && \
    apt-get remove -y unzip && \
    apt-get clean

RUN mv dependency-check /usr/share/

ENV DATA_DIR /usr/share/dependency-check/data
ENV REPORT_DIR /usr/src/app/reports
ENV SRC_DIR /usr/src/app/src


RUN mkdir -p ${DATA_DIR}
RUN mkdir -p ${REPORT_DIR}
RUN mkdir -p ${SRC_DIR}

VOLUME ["/usr/share/dependency-check/data"]


CMD ["/usr/share/dependency-check/bin/dependency-check.sh", "--data", "${DATA_DIR}", "--out", "${REPORT_DIR}", "--scan", "${SRC_DIR}"]
