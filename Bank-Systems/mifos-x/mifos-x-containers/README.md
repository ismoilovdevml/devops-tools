# Mifos X - Containers

Quick Deployment tool for having a running, non persistent Mifos X environment for demonstration purpose. These are samples for quick demo setup, they don't have persistence storage. And they use the lastest version of Apache Fineract and Mifos Web App. 

Don't use in production before doing software hardening and adding trusted TLS certificates. Also we suggest to use stable versions for Production environment.

This have been tested using:

Linux Ubuntu 22.04 LTS
Docker 23.0.1 

Make sure that the ports 8443 and 4200 are free before running the docker compose.

***********************************************************************************************
For running Mifos X using MariaDb as Database
***********************************************************************************************

```bash
cd mariadb
docker compose pull
docker compose up -d
```
Wait some time, because the data is being created. Then go to your web browser and open the following URL to allow the self signed certificate.

https://localhost:8443

Then open the Mifos Web App using mifos as user and password as password

http://localhost:4200

***********************************************************************************************
For running Mifos X using MySQL as Database
***********************************************************************************************

```bash
cd mysql
docker compose pull
docker compose up -d
```
Wait some time, because the data is being created. Then go to your web browser and open the following URL to allow the self signed certificate.

https://localhost:8443

Then open the Mifos Web App using mifos as user and password as password

http://localhost:4200

***********************************************************************************************
For running Mifos X using Postgres as Database
***********************************************************************************************

```bash
cd postgresql
docker compose pull
docker compose up -d
```
Wait some time, because the data is being created. Then go to your web browser and open the following URL to allow the self signed certificate.

https://localhost:8443

Then open the Mifos Web App using mifos as user and password as password

http://localhost:4200

