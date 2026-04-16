# Optimized Dockerfile — dependency layer cached separately from source code
# Fix: Copy package files first so npm ci only re-runs when dependencies change

FROM node:20-alpine AS builder
WORKDIR /app

# ✅ Copy only dependency manifests first
# Docker cache is only invalidated when package.json or package-lock.json changes
COPY package.json package-lock.json ./
RUN npm ci

# ✅ Copy source code after npm ci
# Code changes no longer invalidate the npm ci layer
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["node", "dist/index.js"]
