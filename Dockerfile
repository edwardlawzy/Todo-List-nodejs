FROM node:22.17.1

WORKDIR /app

COPY package*.json ./

RUN npm install mongodb

COPY . .

ENV PORT=8080

EXPOSE 8080

CMD [ "npm", "start" ]