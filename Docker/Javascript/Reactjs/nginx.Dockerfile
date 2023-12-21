FROM node:latest as builder
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install
COPY . .

RUN npm run build
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN sed -i -e 's/80/3000/g' /etc/nginx/conf.d/default.conf

EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]