# BurgerNabijeBesluitendatabank (back-end)

[The back-end for BNB](https://burgernabije-besluitendatabank-dev.s.redhost.be/), a site that uses linked data to empower everyone in Flanders to consult the decisions made by their local authorities.

You can check out more info on besluitendatabanken [here](https://lokaalbestuur.vlaanderen.be/besluitendatabank), and the [back-end](https://github.com/lblod/frontend-burgernabije-besluitendatabank) here. The front-end repo only contains front-end specific information, back-and and general project info will be added here.


## How-To
*Pre-requisities: Docker & Docker-Compose installed. Some parts of the tutorials may use drc as an alias for docker-compose*

### Setup
```bash
git clone https://github.com/lblod/app-burgernabije-besluitendatabank.git
cd app-burgernabije-besluitendatabank.git
docker-compose up --detach
```

### Sync data from lblod-harvester
Setting up the sync should happen work with the following steps:
- ensure docker-compose.override.yml has AT LEAST the following information
```yml
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
```yml
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
