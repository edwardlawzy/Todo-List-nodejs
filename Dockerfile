FROM node:22.17.1

WORKDIR /app

COPY package*.json ./

RUN npm install mongodb

COPY . .

ENV PORT=4000

EXPOSE 4000

CMD [ "npm", "start", "echo" ]