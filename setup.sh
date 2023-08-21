#!/bin/bash
clear

echo "Determining docker compose command..."
if ! type "docker compose" > /dev/null; then
  # install foobar here
  drc="docker-compose "
else
  drc="docker compose "
fi

if test -f "docker-compose.yml"; then
    echo "Found local installation, continuing..."
else
  echo "Cloning repository..."
  git clone https://github.com/lblod/app-burgernabije-besluitendatabank.git
  echo "Moving into folder..."
  cd app-burgernabije-besluitendatabank
fi

echo "Running initial sync..."
cp docker-compose.override.example.yml docker-compose.override.yml
sed -i 's/DCR_DISABLE_DELTA_INGEST: "false"/DCR_DISABLE_DELTA_INGEST: "true"/g' docker-compose.override.yml
sed -i 's/DCR_DISABLE_INITIAL_SYNC: "false"/DCR_DISABLE_INITIAL_SYNC: "true"/g' docker-compose.override.yml

$drc -f docker-compose.yml -f docker-compose.override.yml up | grep -m 1 "All migrations executed"

echo "Finished initial sync, enabling consumers..."
sed -i 's/DCR_DISABLE_DELTA_INGEST: "true"/DCR_DISABLE_DELTA_INGEST: "false"/g' docker-compose.override.yml
sed -i 's/DCR_DISABLE_INITIAL_SYNC: "true"/DCR_DISABLE_INITIAL_SYNC: "false"/g' docker-compose.override.yml


echo "Select environment setup"
select SOURCE in "dev" "qa" "prod"
do
    BESLUITEN_URL=""
    MANDATENDATABANK_URL=""
    OP_PUBLIC_URL=""

    case $SOURCE in
    "dev")
        BESLUITEN_URL="https://dev.harvesting-self-service.lblod.info/"
        MANDATENDATABANK_URL="https://dev.loket.lblod.info/"
        OP_PUBLIC_URL="https://dev.organisaties.abb.lblod.info/"
        break
        ;;
    "qa")
        BESLUITEN_URL="https://qa.harvesting-self-service.lblod.info/"
        MANDATENDATABANK_URL="https://loket.lblod.info/"
        OP_PUBLIC_URL="https://organisaties.abb.lblod.info/"
        break
        ;;
    "prod")
        BESLUITEN_URL=""
        MANDATENDATABANK_URL="https://loket.lokaalbestuur.vlaanderen.be/"
        OP_PUBLIC_URL="https://organisaties.abb.vlaanderen.be/"
        break
        ;;
    esac
done


sed -i "s/MANDATENDATABANK_URL/${MANDATENDATABANK_URL//\//\\/}/" docker-compose.override.yml
sed -i "s/OP_PUBLIC_URL/${OP_PUBLIC_URL//\//\\/}/g" docker-compose.override.yml
sed -i "s/BESLUITEN_URL/${BESLUITEN_URL//\//\\/}/g" docker-compose.override.yml


read -p "Enable plausible analytics? [y/N]: " enableplausible
if [[ $enableplausible =~ ^[Yy] ]]
then
  echo "Configuring plausible analytics..."
  read -p "Plausible API host: " EMBER_PLAUSIBLE_APIHOST
  read -p "Plausible domain: " EMBER_PLAUSIBLE_DOMAIN




  sed -i "s/services:/services:\n  frontend:\n    environment:\n      EMBER_PLAUSIBLE_APIHOST: \"$EMBER_PLAUSIBLE_APIHOST\"\n      EMBER_PLAUSIBLE_DOMAIN: \"$EMBER_PLAUSIBLE_DOMAIN\"\n/" docker-compose.override.yml
fi


echo "Running app-burgernabije-besluitendatabank..."
$drc -f docker-compose.yml -f docker-compose.override.yml

