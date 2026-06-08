###--------BUILD STAGE--------###

FROM   node:20-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci  
COPY   . .
RUN npm run build

###--------PRODUCTION STAGE--------###
FROM nginxinc/nginx-unprivileged:alpine
USER root  
##Switch to root to perform necessary system cleanup

RUN rm -rf /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*

COPY --from=builder /app/dist /usr/share/nginx/html

COPY default.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
#prevent Nginx from crashing due to "Permission Denied" errors when it tries to write its temporary files.
RUN mkdir -p /tmp/client_temp /tmp/proxy_temp /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp
RUN chown -R nginx:nginx /tmp/

RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

USER nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]


