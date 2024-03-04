## Docker Stats

A web application that displays the status of Docker Containers in real-time.

Launch the program

> Required: Nodejs,npm and pm2
> sudo apt install nodejs npm

```bash
git clone https://github.com/ismoilovdevml/devops-tools.git

cd devops-tools/Docker/docker-stats

npm install

npm install pm2 -g

pm2 start ecosystem.config.js

pm2 ls
```