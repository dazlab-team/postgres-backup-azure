#! /bin/sh

set -e

if [ "${AZURE_STORAGE_ACCOUNT}" = "" ]; then
  echo "You need to set the AZURE_STORAGE_ACCOUNT environment variable."
  exit 1
fi

if [ "${AZURE_CONTAINER_NAME}" = "" ]; then
  echo "You need to set the AZURE_CONTAINER_NAME environment variable."
  exit 1
fi

if [ "${AZURE_STORAGE_KEY}" = "" ]; then
  echo "You need to set the AZURE_STORAGE_KEY environment variable."
  exit 1
fi

if [ "${POSTGRES_DATABASE}" = "" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ "${POSTGRES_PORT}" = "" ]; then
  POSTGRES_PORT=5432
fi

if [ "${POSTGRES_HOST}" = "" ]; then
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ "${POSTGRES_USER}" = "" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

echo "Creating dump of ${POSTGRES_DATABASE} database from ${POSTGRES_HOST}..."

export PGPASSWORD=$POSTGRES_PASSWORD
# shellcheck disable=SC2086
pg_dump -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" $POSTGRES_DATABASE $POSTGRES_EXTRA_OPTS | gzip >dump.sql.gz

echo "Uploading dump to $AZURE_STORAGE_ACCOUNT/$AZURE_CONTAINER_NAME"

DATE=$(date +'%Y-%m-%dT%H:%M:%SZ')
START=$(date -u -d "-1 day" '+%Y-%m-%dT%H:%M:%SZ')
EXPIRE=$(date -u -d "3 months" '+%Y-%m-%dT%H:%M:%SZ')
AZURE_STORAGE_SAS_TOKEN=$(az storage account generate-sas \
  --account-name "$AZURE_STORAGE_ACCOUNT" \
  --account-key "$AZURE_STORAGE_KEY" \
  --start "$START" \
  --expiry "$EXPIRE" \
  --https-only \
  --resource-types sco \
  --services b \
  --permissions dlrw -o tsv | sed 's/%3A/:/g;s/\"//g')

./azcopy cp dump.sql.gz "https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/${AZURE_CONTAINER_NAME}/${POSTGRES_DATABASE}_${DATE}.sql.gz?${AZURE_STORAGE_SAS_TOKEN}" || exit 2

echo "SQL backup uploaded successfully"

rm dump.sql.gz
