FROM node:20-alpine AS builder
WORKDIR /app

# ✅ Step 1: Copy only dependency manifests first
# npm ci layer only invalidates when package.json/package-lock.json changes
COPY package.json package-lock.json ./

# ✅ Step 2: Use mount cache for npm — never re-downloads tarballs
# even across separate Docker builds on the same runner
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# ✅ Step 3: Copy source code after dependencies
# Code changes don't invalidate the npm ci layer
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["node", "dist/index.js"]