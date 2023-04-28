(in-package :mu-cl-resources)

(defparameter *cache-count-queries* nil)
(defparameter *supply-cache-headers-p* t
  "when non-nil, cache headers are supplied.  this works together with mu-cache.")
(setf *cache-model-properties-p* t)

(defparameter *include-count-in-paginated-responses* t
  "when non-nil, all paginated listings will contain the number
   of responses in the result object's meta.")
(defparameter *max-group-sorted-properties* nil)

(read-domain-file "domain_agenda-items.json")
(read-domain-file "subdomain_sessions.json")

(read-domain-file "subdomain_votings.json")
(read-domain-file "subdomain_governing-agents.json")
(read-domain-file "subdomain_agents.json")
(read-domain-file "subdomain_decisions.json")

(read-domain-file "subdomain_handled-agenda-items.json")
