# mu-project

Bootstrap a mu.semte.ch microservices environment in three easy steps.

## How to

Setting up your environment is done in three easy steps:  first you configure the running microservices and their names in `docker-compose.yml`, then you configure how requests are dispatched in `config/dispatcher.ex`, and lastly you start everything.

### Hooking things up with docker-compose

Alter the `docker-compose.yml` file so it contains all microservices you need.  The example content should be clear, but you can find more information in the [Docker Compose documentation](https://docs.docker.com/compose/).  Don't remove the `identifier` and `db` container, they are respectively the entry-point and the database of your application.  Don't forget to link the necessary microservices to the dispatcher and the database to the microservices.

### Configure the dispatcher

Next, alter the file `config/dispatcher.ex` based on the example that is there by default.  Dispatch requests to the necessary microservices based on the names you used for the microservice.

### Boot up the system

Boot your microservices-enabled system using docker-compose.

    cd /path/to/mu-project
    docker-compose up

You can shut down using `docker-compose stop` and remove everything using `docker-compose rm`.

### sync data from lblod-harvester
Setting up the sync should happen work with the following steps:
- ensure docker-compose.override.yml has AT LEAST the following information
```
version: '3.7'

services:
#(...) there might be other services

  besluiten-consumer:
    environment:
      DCR_SYNC_BASE_URL: "https://qa.harvesting-self-service.lblod.info/" # you choose endpoint here
      DCR_DISABLE_INITIAL_SYNC: "true"
# (...) there might be other information
```
- start the stack. `drc up -d`. Ensure the migrations have run and finished `drc logs -f --tail=100 migrations`
- Now the sync can be started. Ensure you update the `docker-compose.override.yml` to
```
version: '3.7'

services:
#(...) there might be other services

  besluiten-consumer:
    environment:
      DCR_SYNC_BASE_URL: "https://qa.harvesting-self-service.lblod.info/" # you choose endpoint here
      DCR_DISABLE_INITIAL_SYNC: "false" # <------ THIS CHANGED
# (...) there might be other information
```
- start the sync `drc up -d besluiten-consumer`.
  Data should be ingesting.
  Check the logs `drc logs -f --tail=200 besluiten-consumer`
