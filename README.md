# App BurgerNabije Besluitendatabank

The backend for BNB, a site that uses linked data to empower everyone in Flanders to consult the decisions made by their local authorities.

Important notes: 
- The frontend code is seperated, and can be found [here](https://github.com/lblod/frontend-burgernabije-besluitendatabank).
- You can check out more info on besluitendatabanken [here](https://lokaalbestuur.vlaanderen.be/besluitendatabank).
- This project is built on the semantic.works stack. See [semantic.works](https://semantic.works/) for more info.

## How to
### Run locally
Running this project requires Docker-Compose to be installed. 

```bash
git clone https://github.com/lblod/app-burgernabije-besluitendatabank.git
cd app-burgernabije-besluitendatabank
docker-compose up
```

## Reference
### Project structure
- [config/](config/): Configuration for the services 
    - [authorization/](config/authorization/): Authorization & access rights. [docs](https://github.com/mu-semtech/mu-authorization/)
    - [consumer](config/consumer/): Data syncing. [docs](https://github.com/lblod/delta-consumer)
    - [dispatcher](config/dispatcher/): Request routing. [docs](https://github.com/mu-semtech/mu-dispatcher)
    - [migrations](config/migrations/): Migration file processing. [docs](https://github.com/mu-semtech/mu-migrations-service)
    - [resources](config/resources/): Linked data to JSON:API. [service docs](https://github.com/mu-semtech/mu-cl-resources)/[json:api docs](https://jsonapi.org/)
    - [virtuoso](config/virtuoso/): Triplestore/linked data database. [docs](https://hub.docker.com/r/redpencil/virtuoso)
- [docker-compose.yml](docker-compose.yml): Entrypoint for the projects' services
- [postman.json](postman.json): Configuration for API testing using [Postman](https://www.postman.com/)
