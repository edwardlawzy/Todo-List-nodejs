FROM node:22-alpine # Alpine is a lightweight distribution, resulting in a smaller final image size.

WORKDIR /app # Set the working directory inside the container to /app.

COPY package*.json ./ # Copy package.json and any package-lock.json files into the working directory.

RUN npm install && npm cache clean --force && apk add --no-cache curl Install Node.js dependencies, clean the npm cache, and install curl.

COPY . ./ # Copy the rest of the application's source code into the working directory.

ENV PORT=4000 # Set an environment variable named PORT with the value 4000.

EXPOSE 4000 # Inform Docker that the container will listen on port 4000 at runtime.

CMD [ "npm", "start"] # This will run the "start" script defined in your package.json
