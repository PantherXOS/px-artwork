;;; GNU Guix web site
;;; Copyright © 2019 Florian Pelz <pelzflorian@pelzflorian.de>
;;; Initially written by sirgazil who waves all
;;; copyright interest on this file.

;;; This module defines HTML parts related to media.

(define-module (apps media templates components)
  #:use-module (apps aux lists)
  #:use-module (apps aux web)
  #:use-module (apps base templates components)
  #:use-module (apps base utils)
  #:use-module (apps media types)
  #:use-module (apps media utils)
  #:use-module (srfi srfi-19)
  #:export (screenshot->shtml
            screenshots-box
            video->shtml
            video-content
            video-preview))


;;;
;;; Components.
;;;

(define (screenshot->shtml shot)
  "Return an SHTML representation of the given screenshot object.

   SHOT (<screenshot>)
     A screenshot object as defined in (apps media types)."
  `(div
    (@ (class "screenshot-preview"))
    (a
     (@ (href ,(guix-url (url-path-join "screenshots"
                                        (screenshot-slug shot) ""))))
     (img
      (@ (class "responsive-image")
         (src ,(screenshot-preview shot))
         (alt "")))
     (span (@ (class "screenshot-inset-shadow")) ""))
    (p ,(screenshot-caption shot) (span (@ (class "hidden")) "."))))


(define* (screenshots-box screenshots #:optional (n 6) #:key shadow)
  "Return SHTML for a box displaying up to N many SCREENSHOTS randomly
chosen at build time.  If SHADOW is true, a shadow is displayed at the
top."
  `(div
    (@ (class ,(string-join `("screenshots-box"
                              ,@(if shadow
                                    '("top-shadow-bg")
                                    '())))))
    ,@(map screenshot->shtml (take-random screenshots n))))



(define (video->shtml video)
  "Return SHTML for a representation of the given video object.

   VIDEO (<video>)
     A video object as defined in (apps media types)."
  `(video
     (@ (class "video-preview")
        (src ,(video-url video))
        (poster ,(video-poster video))
        (controls "controls"))
      ;; TODO: Insert missing video-tracks.
      (p
       "Download video: "
       ,(link-subtle
         #:label (video-title video)
         #:url (video-url video)))))


(define (video-preview video)
  "Return SHTML for a box with a representation of the given video
object.

   VIDEO (<video>)
     A video object as defined in (apps media types)."
  `(div
    (@ (class "item-preview"))
    ,(video->shtml video)
    ,(link-light
      #:label (video-title video)
      #:url (guix-url (video->url video)))))


(define (video-content video)
  "Return SHTML with a representation and detailed information for the
given video object.

   VIDEO (<video>)
     A video object as defined in (apps media types)."
  `(div
    ,(video->shtml video)
    ,(video-description video)
    ,(let ((date (video-last-updated video)))
       (if date
           `(p "Last updated: " ,(date->string date))
           ""))))
