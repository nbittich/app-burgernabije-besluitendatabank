(in-package :mu-cl-resources)

(define-resource administrative-unit ()
  :class (s-prefix "besluit:Bestuurseenheid")
  :properties `((:name :string ,(s-prefix "skos:prefLabel")))
  :has-one `((location :via ,(s-prefix "besluit:werkingsgebied")
                       :as "location")
             (administrative-unit-classification-code :via ,(s-prefix "besluit:classificatie")
                                                      :as "classification"))
  :has-many `((governing-body :via ,(s-prefix "besluit:bestuurt")
                              :inverse t
                              :as "governing-bodies"))
  :resource-base (s-url "http://data.lblod.info/id/bestuurseenheden/")
  :features '(include-uri)
  :on-path "administrative-units")

(define-resource administrative-unit-classification-code ()
  :class (s-prefix "ext:BestuurseenheidClassificatieCode")
  :properties `((:label :string ,(s-prefix "skos:prefLabel")))
  :resource-base (s-url "http://data.vlaanderen.be/id/concept/BestuurseenheidClassificatieCode/")
  :features '(include-uri)
  :on-path "administrative-unit-classification-codes")

(define-resource agenda-item ()
  :class (s-prefix "besluit:Agendapunt")
  :properties `((:description :string ,(s-prefix "dct:description"))
                (:planned-public :boolean ,(s-prefix "besluit:geplandOpenbaar"))
                (:public :boolean ,(s-prefix "besluit:openbaar"))
                (:title :string ,(s-prefix "dct:title"))
                (:type :uri-set ,(s-prefix "besluit:Agendapunt.type"))
                (:alternate-link :string ,(s-prefix "prov:wasDerivedFrom"))
                )
  :has-one `((agenda-item :via ,(s-prefix "besluit:aangebrachtNa")
                          :as "added-after")
             (agenda-item-handling :via ,(s-prefix "dct:subject")
                                   :inverse t
                                   :as "handled-by")
             (session :via ,(s-prefix "besluit:behandelt")
                      :inverse t
                      :as "session"))
  :resource-base (s-url "http://data.lblod.info/id/agendapunten/")
  :features '(include-uri)
  :on-path "agenda-items")

(define-resource agenda-item-handling ()
  :class (s-prefix "besluit:BehandelingVanAgendapunt")
  :properties `((:public :boolean ,(s-prefix "besluit:openbaar")))
  :has-many `((resolution :via ,(s-prefix "prov:generated")
                          :as "resolutions")
              (mandatary :via ,(s-prefix "besluit:heeftAanwezige")
                         :as "has-presents")
              (vote :via ,(s-prefix "besluit:heeftStemming")
                    :as "has-votes"))
  :has-one `((agenda-item-handling :via ,(s-prefix "besluit:gebeurtNa")
                                   :as "takes-place-after")
             (agendapunt :via ,(s-prefix "dct:subject")
                         :as "subject")
             (mandatary :via ,(s-prefix "besluit:heeftSecretaris")
                        :as "has-secretary")
             (mandatary :via ,(s-prefix "besluit:heeftVoorzitter")
                        :as "has-chairman"))
  :resource-base (s-url "http://data.lblod.info/id/behandelingen-van-agendapunt")
  :features '(include-uri)
  :on-path "agenda-item-handlings")

(define-resource governing-body ()
  :class (s-prefix "besluit:Bestuursorgaan")
  :properties `((:name :string ,(s-prefix "skos:prefLabel"))
                (:end-date :date ,(s-prefix "mandaat:bindingEinde"))
                (:start-date :date ,(s-prefix "mandaat:bindingStart")))
  :has-one `((administrative-unit :via ,(s-prefix "besluit:bestuurt")
                                  :as "administrative-unit")
  ;;            (bestuursorgaan-classificatie-code :via ,(s-prefix "besluit:classificatie")
  ;;                                               :as "classificatie")
  ;;            (bestuursorgaan :via ,(s-prefix "mandaat:isTijdspecialisatieVan")
  ;;                            :as "is-tijdsspecialisatie-van")
  ;;            (rechtstreekse-verkiezing :via ,(s-prefix "mandaat:steltSamen")
  ;;                                     :inverse t
  ;;                                     :as "wordt-samengesteld-door")
  )
  ;; :has-many `((bestuursorgaan :via ,(s-prefix "mandaat:isTijdspecialisatieVan")
  ;;                      :inverse t
  ;;                      :as "heeft-tijdsspecialisaties")
  ;;             (mandaat :via ,(s-prefix "org:hasPost")
  ;;                      :as "bevat")
  ;;             (bestuursfunctie :via ,(s-prefix "lblodlg:heeftBestuursfunctie")
  ;;                              :as "bevat-bestuursfunctie"))
  :resource-base (s-url "http://data.lblod.info/id/bestuursorganen/")
  :features '(include-uri)
  :on-path "governing-bodies")

(define-resource location ()
  :class (s-prefix "prov:Location")
  :properties `((:label :string ,(s-prefix "rdfs:label"))
                (:niveau :string , (s-prefix "ext:werkingsgebiedNiveau")))
  :has-many `((administrative-unit :via ,(s-prefix "besluit:werkingsgebied")
                                   :inverse t
                                   :as "administrative-units"))
  :resource-base (s-url "http://data.lblod.info/id/werkingsgebieden/")
  :features '(include-uri)
  :on-path "locations")

(define-resource resolution ()
  :class (s-prefix "besluit:Besluit")
  :properties `((:description :string ,(s-prefix "eli:description"))
                ;; broken: mixed type (langString, string)
                ;; (:motivation :language-string ,(s-prefix "besluit:motivering"))
                (:publication-date :date ,(s-prefix "eli:date_publication"))
                ;; broken: mixed type (langString, string, Literal) + Literal not supported by mu-cl-resources 
                (:value :string ,(s-prefix "prov:value"))
                (:language :url ,(s-prefix "eli:language"))
                (:title :string ,(s-prefix "eli:title"))
                (:score :float ,(s-prefix "nao:score")))
  :has-one `(
    ;; (rechtsgrond-besluit :via ,(s-prefix "eli:realizes")
    ;;                               :as "realisatie")
             (agenda-item-handling :via ,(s-prefix "prov:generated")
                                         :inverse t
                                         :as "generated-by"))
  ;; :has-many `((published-resource :via ,(s-prefix "prov:wasDerivedFrom")
  ;;                                 :as "publications"))
  :resource-base (s-url "http://data.lblod.info/id/besluiten/")
  :features '(include-uri)
  :on-path "resolutions")

;;TODO how to relate to superclass 'Agent' for heeftAanwezige
(define-resource session ()
  :class (s-prefix "besluit:Zitting")
  :properties `((:planned-start :datetime ,(s-prefix "besluit:geplandeStart"))
                (:started-at :datetime ,(s-prefix "prov:startedAtTime"))
                (:ended-at :datetime ,(s-prefix "prov:endedAtTime")))
  :has-many `((mandatary :via ,(s-prefix "besluit:heeftAanwezigeBijStart")
                         :as "attendees-at-start")
              (agenda-item :via ,(s-prefix "besluit:behandelt")
                           :as "agenda-items")
            ;;   (uittreksel :via ,(s-prefix "ext:uittreksel")
            ;;               :as "uittreksels")
            ;;   (agenda :via ,(s-prefix "ext:agenda")
            ;;               :as "agendas")
            )
  :has-one `((governing-body :via ,(s-prefix "besluit:isGehoudenDoor")
                             :as "governing-body")
             (mandatary :via ,(s-prefix "besluit:heeftSecretaris")
                        :as "has-secretary")
             (mandatary :via ,(s-prefix "besluit:heeftVoorzitter")
                        :as "has-chairman")
            ;;  (notulen :via ,(s-prefix "besluit:heeftNotulen")
            ;;           :as "notulen")
            ;;  (besluitenlijst :via ,(s-prefix "ext:besluitenlijst")
            ;;           :as "besluitenlijst")
                      )
  :resource-base (s-url "http://data.lblod.info/id/zittingen/")
  :features '(include-uri)
  :on-path "sessions")
  
(define-resource vote ()
  :class (s-prefix "besluit:Stemming")
  :properties `((:number-of-abstentions :number ,(s-prefix "besluit:aantalOnthouders"))
                (:number-of-opponents :number ,(s-prefix "besluit:aantalTegenstanders"))
                (:number-of-proponents :string ,(s-prefix "besluit:aantalVoorstanders"))
                (:secret :boolean ,(s-prefix "besluit:geheim"))
                (:title :string ,(s-prefix "dct:title"))
                ;; besluit:gevolg and besluit:onderwerp has type broken in harvester
                ;; (:consequence :language-string ,(s-prefix "besluit:gevolg"))
                ;; (:subject :language-string ,(s-prefix "besluit:onderwerp"))
                )
  :has-many `((mandatary :via ,(s-prefix "besluit:heeftAanwezige")
                         :as "has-presents")
              (mandatary :via ,(s-prefix "besluit:heeftOnthouder")
                         :as "has-abstainers")
              (mandatary :via ,(s-prefix "besluit:heeftStemmer")
                         :as "has-voters")
              (mandatary :via ,(s-prefix "besluit:heeftTegenstander")
                         :as "has-opponents")
              (mandatary :via ,(s-prefix "besluit:heeftVoorstander")
                         :as "has-proponents"))
  :resource-base (s-url "http://data.lblod.info/id/stemmingen/")
  :features '(include-uri)
  :on-path "votes")
