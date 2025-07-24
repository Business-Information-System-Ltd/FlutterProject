FROM node:20-alpine
RUN npm install -g http-server
WORKDIR /app
COPY build/web /app/
EXPOSE 8090
CMD [ "http-server", "-p","8090" ]