# postgres-backup-azure

A Docker image for performing PostgreSQL backups to Azure Storage

## PostgreSQL version support

Up to 12.5.

## Usage

### Run via Docker 

```
docker run \
 -e POSTGRES_HOST=<db host> \
 -e POSTGRES_DATABASE=<your db name> \
 -e POSTGRES_USER=<your pg username> \
 -e POSTGRES_PASSWORD=<your secret> \
 -e AZURE_STORAGE_ACCOUNT=<your azure storage account name> \
 -e AZURE_CONTAINER_NAME=<existing container name> \
 -e AZURE_STORAGE_KEY=<azure storage key> \
 dazlabteam/postgres-backup-azure
```

### Run via Docker Compose

Edit your Docker Compose file, add new `backup` service:

```
  db:
    image: postgres:12
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: <your pg username>
      POSTGRES_PASSWORD: <your secret>
      POSTGRES_DB: <your db name>

  ...

  backup:
    image: dazlabteam/postgres-backup-azure:12
    environment:
      POSTGRES_HOST: db
      POSTGRES_DATABASE: <your db name>
      POSTGRES_USER: <your pg username>
      POSTGRES_PASSWORD: <your secret>
      AZURE_STORAGE_ACCOUNT: <your azure storage account name>
      AZURE_CONTAINER_NAME: <existing container name>
      AZURE_STORAGE_KEY: <azure storage key>
```

Then run
 
```
docker-compose -f <path to docker compose yaml> run --rm backup
```

or by specifying env variables via the command line:

```
docker-compose -f <path to docker compose yaml> run --rm \
 -e POSTGRES_HOST=<db host> \
 -e POSTGRES_DATABASE=<your db name> \
 -e POSTGRES_USER=<your pg username> \
 -e POSTGRES_PASSWORD=<your secret> \
 -e AZURE_STORAGE_ACCOUNT=<your azure storage account name> \
 -e AZURE_CONTAINER_NAME=<existing container name> \
 -e AZURE_STORAGE_KEY=<azure storage key> \
 backup
```

### Schedule inside Kubernetes Cluster

Create Kubernetes secret containing all the environment variables:

```
kubectl create secret generic postgres-backup-azure \
 --from-literal=POSTGRES_HOST=<db host> \
 --from-literal=POSTGRES_DATABASE=<your db name> \
 --from-literal=POSTGRES_USER=<your pg username> \
 --from-literal=POSTGRES_PASSWORD=<your secret> \
 --from-literal=AZURE_STORAGE_ACCOUNT=<your azure storage account name> \
 --from-literal=AZURE_CONTAINER_NAME=<existing container name> \
 --from-literal=AZURE_STORAGE_KEY=<azure storage key>
```

then create CronJob using the cronjob spec file from this repo:

```
kubectl apply -f postgres-backup-azure.cronjob.yaml
```

By default, it will run every day at 00:00. To change this, edit cronjob and specify 
other schedule:

```
kubectl edit cronjob postgres-backup-azure
```

## License

MIT

## Links

 - https://hub.docker.com/r/dazlabteam/postgres-backup-azure
 - https://github.com/schickling/dockerfiles/tree/master/postgres-backup-s3
 - https://docs.microsoft.com/en-us/previous-versions/azure/storage/storage-use-azcopy-linux
 - https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/
 - https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
 