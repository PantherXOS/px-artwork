;;; GNU Guix web site
;;; Initially written by sirgazil who waives all
;;; copyright interest on this file.

(define-module (apps aux strings)
  #:export (string-summarize))


(define (string-summarize string n)
  "Return an extract of N words from the given STRING."
  (let ((words (string-split string #\space)))
    (if (<= (length words) n)
	string
	(string-join (list-head words n) " "))))
