FROM makuk66/docker-solr:5.2
MAINTAINER Dan Michael O. Heggø <d.m.heggo@ub.uio.no>

ADD ./ccmapper/core.properties /opt/solr/server/solr/ccmapper/core.properties
ADD ./ccmapper/conf /opt/solr/server/solr/ccmapper/conf

USER root
RUN chown -R $SOLR_USER:$SOLR_USER /opt/solr/server/solr/ccmapper
USER $SOLR_USER

VOLUME /opt/solr/server/solr/ccmapper/conf
