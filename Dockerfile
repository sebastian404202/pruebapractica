FROM rhel7
 
 
RUN yum clean all && \
    yum repolist --disablerepo="*" && \
    yum-config-manager --disable "*" && \
    yum-config-manager --enable rhel-7-server-rpms && \
    yum clean all && \
    yum-config-manager \
                       --enable rhel-7-server-restricted-maintenance-oracle-java-rpms \
                       --enable rhel-7-server-supplementary-rpms \
                       --enable rhel-7-server-optional-rpms && \
    yum clean all && \
    yum -y update && \
    yum -y install procps iproute yum-utils tar unzip
 
# Set time zone to America/Bogota
ENV TZ="America/Bogota"
RUN pushd /etc &&  \
    rm -f localtime &&  \
    ln -s "../usr/share/zoneinfo/${TZ}" localtime
	

ENV JAVA_UPDATE_VERSION="202"
COPY "common/jdk-8u${JAVA_UPDATE_VERSION}-linux-x64.rpm" /opt/app/common/
RUN yum -y localinstall "/opt/app/common/jdk-8u${JAVA_UPDATE_VERSION}-linux-x64.rpm" && rm -f "/opt/app/common/jdk-8u${JAVA_UPDATE_VERSION}-linux-x64.rpm"

ENV JDK_VERSION="1.8.0" \
    JDK_VENDOR="oracle" \
    JAVA_HOME="/usr/java/jdk1.8.0_${JAVA_UPDATE_VERSION}-amd64"


RUN mkdir /usr/lib/jvm && ln -s "${JAVA_HOME}" "/usr/lib/jvm/java-${JDK_VERSION}-${JDK_VENDOR}"

COPY "common/${JDK_POLICY_FILE}" /opt/app/common/
RUN unzip -B -o -j -d "${JAVA_HOME}/jre/lib/security/" "/opt/app/common/${JDK_POLICY_FILE}" *US_export_policy.jar *README.txt *local_policy.jar &&  \
    rm -f "/opt/app/common/${JDK_POLICY_FILE}"
	

LABEL jdk.version="${JDK_VERSION}" \
      jdk.vendor="${JDK_VENDOR}"
	  
ENV APP_NAME="apli-0.0.1-SNAPSHOT" \
    APP_TYPE="jvm" \
    APP_PORT="9406" \

LABEL docker.version="1.0" \

EXPOSE 9406
 
RUN mkdir -p /opt/app/run/apli/ && \
    chown daemon:root /opt/app/run/apli/ && \
    mkdir -p /opt/app/logs/apli/ && \
    chown daemon:root /opt/app/logs/apli/
 
COPY apli/jvm-exec-wrapper /opt/app/aplicaciones/apli/
COPY apli/shared/ /opt/app/shared/apli/

COPY apli-0.0.1-SNAPSHOT.jar /opt/app/aplicaciones/apli/apli-0.0.1-SNAPSHOT.jar
 
RUN chmod +rx /opt/app/aplicaciones/apli/jvm-exec-wrapper && \
    chown -R root:daemon /opt/app/shared/apli && \
    find /opt/app/shared/apli -exec chmod g+rX '{}' ';' && \
    chown -R root:daemon /opt/app/aplicaciones/apli && \
    chown -R root:daemon /opt/app/shared/apli/ && \
    find /opt/app/aplicaciones/apli -exec chmod g+rX '{}' ';' && \
    find /opt/app/shared/apli/ -exec chmod g+rX '{}' ';'
 
USER daemon
ENTRYPOINT ["/bin/sh", "-c", "exec /opt/app/aplicaciones/apli/jvm-exec-wrapper"]
