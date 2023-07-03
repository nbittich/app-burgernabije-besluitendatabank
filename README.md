# Burgernabije Besluitendatabank (back-end)

[The back-end for BNB](https://burgernabije-besluitendatabank-dev.s.redhost.be/), a site that uses linked data to empower everyone in Flanders to consult the decisions made by their local authorities.

You can check out more info on besluitendatabanken [here](https://lokaalbestuur.vlaanderen.be/besluitendatabank), and the [back-end](https://github.com/lblod/frontend-burgernabije-besluitendatabank) here. The front-end repo only contains front-end specific information, back-and and general project info will be added here.

## How-To

**Pre-requisites**: Docker & Docker-Compose installed. Some parts of the tutorials may use drc as an alias for docker-compose

### Setup

```bash
git clone https://github.com/lblod/app-burgernabije-besluitendatabank.git
cd app-burgernabije-besluitendatabank.git
docker-compose up --detach
```

### Sync data external data consumers
The procedure below describes how to set up the sync for besluiten-consumer.
The procedures should be the similar for `op-public-consumer` and `mandatendatabank-consumer`.

#### From scratch
Setting up the sync should happen work with the following steps:

- ensure docker-compose.override.yml has AT LEAST the following information

```yml
version: '3.7'

services:
#(...) there might be other services

  besluiten-consumer:
    environment:
      DCR_SYNC_BASE_URL: "https://qa.harvesting-self-service.lblod.info/" # you choose endpoint here
      DCR_DISABLE_DELTA_INGEST: "true"
      DCR_DISABLE_INITIAL_SYNC: "true"
# (...) there might be other information
```

- start the stack. `drc up -d`. Ensure the migrations have run and finished `drc logs -f --tail=100 migrations`
- Now the sync can be started. Ensure you update the `docker-compose.override.yml` to

```yml
version: '3.7'

services:
#(...) there might be other services

  besluiten-consumer:
    environment:
      DCR_SYNC_BASE_URL: "https://qa.harvesting-self-service.lblod.info/" # you choose endpoint here
      DCR_DISABLE_DELTA_INGEST: "false" # <------ THIS CHANGED
      DCR_DISABLE_INITIAL_SYNC: "false" # <------ THIS CHANGED
# (...) there might be other information
```

- start the sync `drc up -d besluiten-consumer`.
  Data should be ingesting.
  Check the logs `drc logs -f --tail=200 besluiten-consumer`

#### In case of a re-sync
In some cases, you may need to reset the data due to unforeseen issues. The simplest method is to entirely flush the triplestore and start afresh. However, this can be time-consuming, and if the app possesses an internal state that can't be recreated from external sources, a more granular approach would be necessary. We will outline this approach here. Currently, it involves a series of manual steps, but we hope to enhance the level of automation in the future.

##### besluiten-consumer

- ensure the app is running and all migrations ran.
- ensure the besluiten-consumer stopped syncing, `docker-compose.override.yml` should AT LEAST contain the following information
```yml
version: '3.7'

services:
#(...) there might be other services

  besluiten-consumer:
    environment:
      DCR_DISABLE_DELTA_INGEST: "true"
      DCR_DISABLE_INITIAL_SYNC: "true"
     # (...) there might be other information e.g. about the endpoint

# (...) there might be other information
```
- `docker-compose up -d besluiten-consumer` to re-create the container.
- We need to flush the ingested data. Sample migrations have been provided.
```
cp ./config/sample-migrations/flush-besluiten-consumer.sparql-template ./config/migrations/local/[TIMESTAMP]-flush-besluiten-consumer.sparql
docker-compose restart migrations
```
- Once migrations a success, further `besluiten-consumer` data needs to be flushed too.
```
docker-compose exec besluiten-consumer curl -X POST http://localhost/flush
docker-compose logs -f --tail=200 besluiten-consumer
```
  - This should end with `Flush successful`.
- Proceed to consuming data from scratch again, ensure `docker-compose.override.yml` should AT LEAST contain the following information
```yml
version: '3.7'

services:
#(...) there might be other services

  besluiten-consumer:
    environment:
      DCR_DISABLE_DELTA_INGEST: "false"
      DCR_DISABLE_INITIAL_SYNC: "false"
     # (...) there might be other information e.g. about the endpoint

# (...) there might be other information
```
- Run `docker-compose up -d`
- This might take a while if `docker-compose logs besluiten-consumer |grep success Returns: Initial sync http://redpencil.data.gift/id/job/URI has been successfully run`; you should be good. (Your computer will also stop making noise)

##### op-public-consumer & mandatendatabank-consumer
As of the time of writing, there is some overlap between the two data producers due to practical reasons. This issue will be resolved eventually. For the time being, if re-synchronization is required, it's advisable to re-sync both consumers. The procedure is identical to the one for besluiten-consumer, but it needs to be performed twice.

#### What endpoints can be used?
##### besluiten-consumer

- Production data: N/A
- QA data: https://qa.harvesting-self-service.lblod.info/
- DEV data: https://dev.harvesting-self-service.lblod.info/

##### mandatendatabank-consumer

- Production data: https://mandaten.lokaalbestuur.vlaanderen.be/
- QA data: https://mandaten.lblod.info/
- DEV data: https://dev.mandaten.lblod.info/

##### op-public-consumer

- Production data: https://organisaties.abb.vlaanderen.be/
- QA data: https://organisaties.abb.lblod.info/
- DEV data: https://dev.organisaties.abb.lblod.info/


## Reference

### Models

This project is built around the following structure:
![Diagram for the relationship models](https://data.vlaanderen.be/doc/applicatieprofiel/besluit-publicatie/html/overview.jpg)

Source: [data.vlaanderen.be](https://data.vlaanderen.be/doc/applicatieprofiel/besluit-publicatie/)
