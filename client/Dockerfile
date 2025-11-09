FROM node:25.1-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Variáveis importantes pro watcher funcionar no Docker
ENV WATCHPACK_POLLING=true
ENV CHOKIDAR_USEPOLLING=true
ENV HOST=0.0.0.0
ENV PORT=4000

EXPOSE 4000

CMD ["npm", "run", "dev", "--", "--hostname", "0.0.0.0", "-p", "4000"]