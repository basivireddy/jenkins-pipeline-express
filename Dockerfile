FROM node:7.4.0
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["sh", "-c", "npm start" ]
