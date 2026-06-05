###-------BUILD STAGE-------###
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json  ./
RUN npm ci --production && npm cache clean --force
COPY . .


###-------PRODUCTION STAGE-------###
FROM node:20-alpine
WORKDIR /app
RUN apk add --no-cache dumb-init
RUN addgroup -S app_user && adduser -S -G app_user app_user
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./
RUN chown -R app_user:app_user /app
USER app_user
EXPOSE 5000
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "/app/src/index.js"]
