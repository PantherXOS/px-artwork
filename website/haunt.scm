;;; GuixSD website --- GNU's advanced distro website
;;; Initially written by sirgazil who waives all
;;; copyright interest on this file.

(use-modules ((apps base builder) #:prefix base:)
	     ((apps blog builder) #:prefix blog:)
	     ((apps download builder) #:prefix download:)
	     ((apps packages builder) #:prefix packages:)
	     (haunt asset)
             (haunt builder assets)
             (haunt reader)
	     (haunt reader commonmark)
             (haunt site))


(site #:title "GuixSD"
      #:domain "https://gnu.org/software/guix"
      ;; BUG: Can't use . in directory names (e.g. /tmp/gnu.org).
      #:build-directory "/tmp/gnu/software/guix"
      #:readers (list sxml-reader html-reader commonmark-reader)
      #:builders (list base:builder
		       blog:builder
		       download:builder
		       packages:builder
		       (static-directory "static")))
