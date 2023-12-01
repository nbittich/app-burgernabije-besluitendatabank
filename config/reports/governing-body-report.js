import { generateReportFromData, batchedQuery } from "../helpers.js";

export default {
  cronPattern: "0 00 23 * * *",
  name: "governing-body-report",
  execute: async () => {
    const reportData = {
      title: "Bestuursorganen",
      description: "Bestuursorganen nummeren",
      filePrefix: "governing-body",
    };

    const queryLocationListResponse = await batchedQuery(queryGoverningBodyList);
    console.log(JSON.stringify(queryLocationListResponse.results));
    console.log(
      `Found ${queryLocationListResponse.results.bindings.length} locations`
    );
    const queryPerLocations = queryLocationListResponse.results.bindings.map(
      ({ location }) => {
        console.log(`Querying location ${location.value}`);
        return queryLocationStats(location.value);
      }
    );
    const bindings = [];
    for (const query of queryPerLocations) {
        const queryResponse = await batchedQuery(query);
        console.log(JSON.stringify(queryResponse.results));
        bindings.push(queryResponse.results.bindings);
      }
    console.log(`Found ${bindings.length} query responses`);
    const data = []
      .concat(...bindings)
      .map(
        ({
          locationLabel,
          governingBodyAbstractClassificationName,
          firstSessionPlannedStart,
          lastSessionPlannedStart,
          firstSessionStartedAt,
          lastSessionStartedAt,
          sessionCount,
          sessionPlannedStartCount,
          sessionStartedAtCount,
          sessionEndedAtCount,
          agendaItemCount,
          agendaItemTitleCount,
          agendaItemDescriptionCount,
          resolutionCount,
          voteCount,
        }) => ({
          Locatie: cleanValue(locationLabel?.value),
          "Bestuursorgaan type": cleanValue(
            governingBodyAbstractClassificationName?.value
          ),
          "Eerste zitting geplande start": cleanValue(
            firstSessionPlannedStart?.value
          ),
          "Laatste zitting geplande start": cleanValue(
            lastSessionPlannedStart?.value
          ),
          "Eerste zitting gestart": cleanValue(firstSessionStartedAt?.value),
          "Laatste zitting gestart": cleanValue(lastSessionStartedAt?.value),
          "Zittingen aantal": cleanValue(sessionCount?.value),
          "Zittingen geplande start aantal": cleanValue(
            sessionPlannedStartCount?.value
          ),
          "Zittingen gestart aantal": cleanValue(sessionStartedAtCount?.value),
          "Zittingen beëindigd aantal": cleanValue(sessionEndedAtCount?.value),
          "Agendapunten aantal": cleanValue(agendaItemCount?.value),
          "Agendapunten titel aantal": cleanValue(agendaItemTitleCount?.value),
          "Agendapunten beschrijving aantal": cleanValue(
            agendaItemDescriptionCount?.value
          ),
          "Agendapunten behandeling aantal": cleanValue(
            agendaItemHandlingCount?.value
            ),
          "Besluiten aantal": cleanValue(resolutionCount?.value),
          "Stemmingen aantal": cleanValue(voteCount?.value),
        })
      );
    console.log(`Found ${data.length} data rows`);
    await generateReportFromData(
      data,
      [
        "Locatie",
        "Bestuursorgaan type",
        "Eerste zitting geplande start",
        "Laatste zitting geplande start",
        "Eerste zitting gestart",
        "Laatste zitting gestart",
        "Zittingen aantal",
        "Zittingen geplande start aantal",
        "Zittingen gestart aantal",
        "Zittingen beëindigd aantal",
        "Agendapunten aantal",
        "Agendapunten titel aantal",
        "Agendapunten beschrijving aantal",
        "Agendapunten behandeling aantal",
        "Besluiten aantal",
        "Stemmingen aantal",
      ],
      reportData
    );
  },
};

const cleanValue = (inputString) => {
  const cleanedString = inputString
    ?.trim()
    // Basic protection against CSV injection
    .replace(/["';=<>]/g, "");

  return `"${cleanedString}"`;
};

/**
 * Query to get all governing bodies and their location
 */
const queryGoverningBodyList = `
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>

SELECT DISTINCT ?governingBodyAbstract ?governingBodyAbstractClassificationName ?locationLabel
WHERE {

    ?governingBodyAbstract a besluit:Bestuursorgaan ;
        besluit:classificatie ?governingBodyAbstractClassification ;
        besluit:bestuurt ?administrativeUnit .

    ?administrativeUnit a besluit:Bestuurseenheid ;
        besluit:werkingsgebied ?location .

    ?location a prov:Location ;
        rdfs:label ?locationLabel .

    ?governingBodyAbstractClassification 
        skos:prefLabel ?governingBodyAbstractClassificationName .
}`;

const queryLocationStats = (location) => `
PREFIX besluit: <http://data.vlaanderen.be/ns/besluit#>
PREFIX mandaat: <http://data.vlaanderen.be/ns/mandaat#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX eli: <http://data.europa.eu/eli/ontology#>
PREFIX code: <http://lblod.data.gift/vocabularies/organisatie/>

SELECT DISTINCT 
    ?locationLabel 
    ?governingBodyAbstractClassificationName 
    (MIN(?sessionPlannedStart) as ?firstSessionPlannedStart)
    (MAX(?sessionPlannedStart) as ?lastSessionPlannedStart)
    (MIN(?sessionStartedAt) as ?firstSessionStartedAt)
    (MAX(?sessionStartedAt) as ?lastSessionStartedAt)
    (COUNT(DISTINCT ?session) AS ?sessionCount)
    (COUNT(DISTINCT ?sessionPlannedStart) AS ?sessionPlannedStartCount)
    (COUNT(DISTINCT ?sessionStartedAt) AS ?sessionStartedAtCount)
    (COUNT(DISTINCT ?sessionEndedAt) AS ?sessionEndedAtCount)
    (COUNT(DISTINCT ?agendaItem) AS ?agendaItemCount)
    (COUNT(DISTINCT ?agendaItemTitle) AS ?agendaItemTitleCount)
    (COUNT(DISTINCT ?agendaItemDescription) AS ?agendaItemDescriptionCount)
    (COUNT(DISTINCT ?agendaItemHandling) AS ?agendaItemHandlingCount)
    (COUNT(DISTINCT ?resolution) AS ?resolutionCount)
    (COUNT(DISTINCT ?resolutionDescription) AS ?resolutionDescriptionCount)
    (COUNT(DISTINCT ?resolutionMotivation) AS ?resolutionMotivationCount)
    (COUNT(DISTINCT ?article) AS ?articleCount)
    (COUNT(DISTINCT ?vote) AS ?voteCount)
    (COUNT(DISTINCT ?voteSubject) AS ?voteSubjectCount)
    (COUNT(DISTINCT ?voteConsequence) AS ?voteConsequenceCount)
    (COUNT(DISTINCT ?voteSecret) AS ?voteSecretCount)
    (COUNT(DISTINCT ?voteNumberOfAbstentions) AS ?voteNumberOfAbstentionsCount)
    (COUNT(DISTINCT ?voteNumberOfOpponents) AS ?voteNumberOfOpponentsCount)
    (COUNT(DISTINCT ?voteNumberOfProponents) AS ?voteNumberOfProponentsCount)
WHERE {
    GRAPH ?g {
        VALUES ?location {
            <${location}>
        }
        
        OPTIONAL {
            ?agendaItemHandling a besluit:BehandelingVanAgendapunt ;
                dct:subject ?agendaItem .
            
            OPTIONAL { 
                ?agendaItemHandling prov:generated ?resolution . 

                OPTIONAL { ?resolution eli:description ?resolutionDescription . }
                OPTIONAL { ?resolution besluit:motivering ?resolutionMotivation . }
                OPTIONAL { ?resolution eli:has_part ?article . }
            }
            OPTIONAL { 
                ?agendaItemHandling besluit:heeftStemming ?vote . 
                
                OPTIONAL { ?vote besluit:onderwerp ?voteSubject . }
                OPTIONAL { ?vote besluit:gevolg ?voteConsequence . }
                OPTIONAL { ?vote besluit:geheim ?voteSecret . }
                OPTIONAL { ?vote besluit:aantalOnthouders ?voteNumberOfAbstentions . }
                OPTIONAL { ?vote besluit:aantalTegenstanders ?voteNumberOfOpponents . }
                OPTIONAL { ?vote besluit:aantalVoorstanders ?voteNumberOfProponents . }
            }
        }

        ?agendaItem a besluit:Agendapunt .

        OPTIONAL { ?agendaItem dct:title ?agendaItemTitle . }
        OPTIONAL { ?agendaItem dct:description ?agendaItemDescription . }

        ?session a besluit:Zitting ;
            besluit:behandelt ?agendaItem .

        OPTIONAL { ?session besluit:geplandeStart ?sessionPlannedStart . }
        OPTIONAL { ?session prov:startedAtTime ?sessionStartedAt . }
        OPTIONAL { ?session prov:endedAtTime ?sessionEndedAt . }

        { 
            ?session a besluit:Zitting ;
                besluit:isGehoudenDoor ?governingBodyTimeSpecified .
    
            ?governingBodyTimeSpecified a besluit:Bestuursorgaan ;
                mandaat:isTijdspecialisatieVan ?governingBodyAbstract .
        }
        UNION { 
            ?session a besluit:Zitting ;
                besluit:isGehoudenDoor ?governingBodyAbstract .
        }

        ?governingBodyAbstract a besluit:Bestuursorgaan ;
            besluit:classificatie ?governingBodyAbstractClassification ;
            besluit:bestuurt ?administrativeUnit .

        ?administrativeUnit a besluit:Bestuurseenheid ;
            besluit:werkingsgebied ?location .

        ?location a prov:Location ;
            rdfs:label ?locationLabel .

        ?governingBodyAbstractClassification 
            skos:prefLabel ?governingBodyAbstractClassificationName .
    }
} GROUP BY ?locationLabel ?governingBodyAbstractClassificationName`;
