FROM node:22-alpine

WORKDIR /app

COPY package*.json ./

#RUN --mount=type=secret,id=MongoDBURL,env=MONGODB_URL

RUN npm install && npm cache clean --force

COPY . ./

ENV PORT=4000

ENV mongoDbUrl=${{secrets.MONGODB_URI}}

EXPOSE 4000

CMD [ "npm", "start"]