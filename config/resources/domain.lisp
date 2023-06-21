(in-package :mu-cl-resources)

;; https://github.com/mu-semtech/mu-cl-resources/blob/master/README.md#external-cache
(defparameter *cache-model-properties* t)
(defparameter *supply-cache-headers-p* t)

(read-domain-file "besluit-domain-en.lisp")
(read-domain-file "mandaat-domain-en.lisp")

(setf *fetch-all-types-in-construct-queries* t)