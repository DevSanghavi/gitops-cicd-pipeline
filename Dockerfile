FROM node:18-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
# Ensure node_modules directory always exists so copying never fails
RUN mkdir -p node_modules && npm ci --omit=dev

FROM node:18-alpine AS runtime
ENV NODE_ENV=production
ENV PORT=3000
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY package.json package-lock.json ./
COPY src ./src
RUN addgroup -S app && adduser -S app -G app && chown -R app:app /app
USER app
EXPOSE 3000
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 CMD wget -qO- http://127.0.0.1:3000/health || exit 1
CMD ["node", "src/server.js"]
