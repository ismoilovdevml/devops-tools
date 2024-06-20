## Grana Loki Promtail


```bash
whoami
mkdir promtail
cd promtail
nano config.yml
sudo nano /etc/promtail/docker-config.yaml
```

```bash
docker run -d --name promtail \
-v /home/user/promtail/config.yml:/etc/promtail/docker-config.yaml \
-v /var/lib/docker/containers:/var/lib/docker/containers:ro \
-v /var/run/docker.sock:/var/run/docker.sock \
grafana/promtail:latest -config.file=/etc/promtail/docker-config.yaml
```