FROM tomcat:9.0.50-jdk11-corretto

ADD ocms.tar.gz $CATALINA_HOME/webapps/
RUN sed -i 's shared.loader shared.loader=${catalina.base}/shared/classes,${catalina.base}/shared/lib/*.jar ' /usr/local/tomcat/conf/catalina.properties && \
    printf '%s\n%s\n' '#TSG ACA requirement' 'org.apache.tomcat.util.buf.UDecoder.ALLOW_ENCODED_SLASH=true' >> /usr/local/tomcat/conf/catalina.properties && \
    yum install -y tree less vim && yum clean all && rm -rf /var/cache/yum
    
