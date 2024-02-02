FROM nodered/node-red
USER root
RUN mkdir -p /data
COPY ./* /data/
RUN chown -R node-red /data
RUN chmod -R 775 /data

USER node-red
RUN cd /data && npm install
ENV PORT 1880
EXPOSE 1880:1880