FROM node:25.1-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM node:25.1-alpine
WORKDIR /app

COPY --from=builder /app ./

EXPOSE 4000
CMD ["npm", "run", "dev", "--", "-p", "4000"]
