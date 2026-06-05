###--------BUILD STAGE--------###

FROM   node:20-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci  
COPY   . .
RUN npm run build

###--------PRODUCTION STAGE--------###
FROM nginx:alpine
RUN rm -rf /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*
COPY --from=builder /app/dist /usr/share/nginx/html
COPY --from=builder /app/build/ /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/conf.d/default.conf

RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid


USER nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]


