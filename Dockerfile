FROM openjdk:8-jre-slim

ENV APP_NAME="apli-0.0.1-SNAPSHOT" \
    APP_TYPE="jvm" \
    APP_PORT="9406" 

LABEL docker.version="1.0" 

EXPOSE 9406
 
RUN mkdir -p /opt/app/run/apli/ && \ 
	mkdir -p /opt/app/aplicaciones/apli && \ 
	mkdir -p /opt/app/shared/apli/ && \ 
    #chown -R root:daemon /opt/app/ 
	
COPY apli/jvm-exec-wrapper /opt/app/aplicaciones/apli
COPY apli/shared/ /opt/app/shared/apli/

COPY apli-0.0.1-SNAPSHOT.jar /opt/app/aplicaciones/apli/apli-0.0.1-SNAPSHOT.jar
 
RUN chmod +rx /opt/app/aplicaciones/apli/jvm-exec-wrapper && \
    #chown -R root:daemon /opt/app/shared/apli && \
    #find /opt/app/shared/apli -exec chmod g+rX '{}' ';' && \
    #chown -R root:daemon /opt/app/aplicaciones/apli && \
    #chown -R root:daemon /opt/app/shared/apli/ && \
    find /opt/app/aplicaciones/apli -exec chmod g+rX '{}' ';' && \
    find /opt/app/shared/apli/ -exec chmod g+rX '{}' ';' && \
    chown -R root:daemon /opt/app/ 	
 
#USER daemon
ENTRYPOINT ["/bin/sh", "-c", "exec /opt/app/aplicaciones/apli/jvm-exec-wrapper"]
