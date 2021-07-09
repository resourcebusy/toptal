FROM node:current

ARG ng_version=latest
RUN npm install -g @angular/cli && \
    ng version

ENTRYPOINT ["ng"]
