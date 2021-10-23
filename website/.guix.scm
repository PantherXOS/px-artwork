;;; GNU Guix web site
;;; Copyright © 2017, 2019, 2020 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2019 Florian Pelz <pelzflorian@pelzflorian.de>
;;;
;;; This file is part of the GNU Guix web site.
;;;
;;; The GNU Guix web site is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; The GNU Guix web site is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with the GNU Guix web site.  If not, see <http://www.gnu.org/licenses/>.

;; Run 'guix build -f .guix.scm' to build the web site.

(define this-directory
  (dirname (current-filename)))

;; Make sure po/LINGUAS will be found in the current working
;; directory.
(chdir this-directory)

;; We need %linguas from the (sexp-xgettext) module.
;; Therefore, we add its path to the load path.
(set! %load-path (cons this-directory %load-path))

(use-modules (guix) (gnu)
             (gnu packages guile)
             (gnu packages guile-xyz)
             (gnu packages package-management)
             (guix modules)
             (guix git-download)
             (guix gexp)
             (guix inferior)
             (guix channels)
             (srfi srfi-1)
             (srfi srfi-9)
             (ice-9 match)
             (ice-9 rdelim)
             (ice-9 regex)
             (sexp-xgettext))

(define source
  (local-file this-directory "guix-web-site"
              #:recursive? #t
              #:select? (git-predicate this-directory)))

(define root-path
  (getenv "GUIX_WEB_SITE_ROOT_PATH"))

(define (package+propagated-inputs package)
  (match (package-transitive-propagated-inputs package)
    (((labels packages) ...)
     (cons package packages))))

;; Representation of the latest channels.  This type exists just so we can
;; refer to such records in a gexp.
(define-record-type <latest-channels>
  (latest-channels channels)
  latest-channels?
  (channels latest-channels-channels))

(define-gexp-compiler (latest-channels-compiler (latest <latest-channels>)
                                                system target)
  (match latest
    (($ <latest-channels> channels)
     (latest-channel-derivation channels))))

(define latest-guix
  ;; The latest Guix.  Using it rather than the 'guix' package ensures we
  ;; build the latest package list.
  (latest-channels %default-channels))

(define (inferior-package spec)
  (first (lookup-inferior-packages
          (inferior-for-channels
           (latest-channels-channels latest-guix))
          spec)))

;; Make sure that Haunt uses the same Guile as the one from
;; "latest-guix". Otherwise there could be a mismatch between the Guile
;; revision used by Haunt and the one from the latest Guix modules used by
;; Haunt.
(define haunt-with-latest-guile
  (package
    (inherit haunt)
    (inputs
     `(("guile" ,(inferior-package "guile"))
       ,@(package-inputs haunt)))))

(define build
  ;; We need Guile-JSON for 'packages-json-builder'.
  (with-extensions (append (package+propagated-inputs
                            (specification->package "guile-json"))

                           (package+propagated-inputs
                            (specification->package "guile-syntax-highlight")))
    (with-imported-modules (source-module-closure
                            '((guix build utils)))
      #~(begin
          (use-modules (guix build utils)
                       (ice-9 popen)
                       (ice-9 match))

          (setvbuf (current-output-port) 'line)
          (setvbuf (current-error-port) 'line)

          (setenv "GUIX_WEB_SITE_LOCAL" "no")
          (copy-recursively #$source ".")

          ;; Set 'GUILE_LOAD_PATH' so that Haunt find the Guix modules and
          ;; its dependencies.  To find out the load path of Guix and its
          ;; dependencies, fetch its value over 'guix repl'.
          (let ((pipe (open-pipe* OPEN_BOTH
                                  #+(file-append latest-guix "/bin/guix")
                                  "repl" "-t" "machine")))
            (pk 'repl-version (read pipe))
            (write '(list %load-path %load-compiled-path) pipe)
            (force-output pipe)
            (match (read pipe)
              (('values ('value ((load-path ...) (compiled-path ...))))
               (setenv "GUILE_LOAD_PATH" (string-join
                                          (append load-path %load-path)
                                          ":"))
               (setenv "GUILE_LOAD_COMPILED_PATH"
                       (string-join (append compiled-path
                                            %load-compiled-path)
                                    ":"))))
            (close-pipe pipe))

          ;; Make the copy writable so Haunt can overwrite duplicate assets.
          (invoke #+(file-append (specification->package "coreutils")
                                 "/bin/chmod")
                  "--recursive" "u+w" ".")

          ;; For translations, create MO files from PO files.
          (for-each
           (lambda (lingua)
             (let* ((msgfmt #+(file-append
                               (specification->package "gettext-minimal")
                               "/bin/msgfmt"))
                    (lingua-file (string-append "po/" lingua ".po"))
                    (lang (car (string-split lingua #\_)))
                    (lang-file (string-append "po/" lang ".po"))
                    (packages-lingua-mo (string-append
                                          #$guix "/share/locale/" lingua
                                          "/LC_MESSAGES/guix-packages.mo"))
                    (packages-lang-mo (string-append
                                        #$guix "/share/locale/" lang
                                        "/LC_MESSAGES/guix-packages.mo")))
               (define (create-mo filename)
                 (begin
                   (invoke msgfmt filename)
                   (mkdir-p (string-append lingua "/LC_MESSAGES"))
                   (rename-file "messages.mo"
                                (string-append lingua "/LC_MESSAGES/"
                                               "guix-website.mo"))))
               (cond
                ((file-exists? lingua-file)
                 (create-mo lingua-file))
                ((file-exists? lang-file)
                 (create-mo lang-file))
                (else #t))
               (cond
                 ((file-exists? packages-lingua-mo)
                  (copy-file packages-lingua-mo
                             (string-append lingua "/LC_MESSAGES/"
                                            "guix-packages.mo")))
                 ((file-exists? packages-lang-mo)
                  (copy-file packages-lang-mo
                             (string-append lingua "/LC_MESSAGES/"
                                            "guix-packages.mo")))
                 (else #t))))
           (list #$@%linguas))

          ;; So we can read/write UTF-8 files.
          (setenv "GUIX_LOCPATH"
                  #+(file-append (specification->package "glibc-locales")
                                 "/lib/locale"))

          ;; Use a sane default.
          (setenv "XDG_CACHE_HOME" "/tmp/.cache")

          ;; Use GUIX_WEB_SITE_ROOT_PATH from the environment in which
          ;; this script was run.
          (setenv "GUIX_WEB_SITE_ROOT_PATH" #$root-path)

          ;; Build the website for each translation.
          (for-each
           (lambda (lingua)
             (begin
               (setenv "LC_ALL" (string-append lingua ".utf8"))
               (format #t "Running 'haunt build' for lingua ~a...~%" lingua)
               (invoke #+(file-append haunt-with-latest-guile
                                      "/bin/haunt")
                       "build")
               (mkdir-p #$output)
               (copy-recursively "/tmp/gnu.org/software/guix" #$output
                                 #:log (%make-void-port "w"))
               (let ((tag (assoc-ref
                           (call-with-input-file "po/ietf-tags.scm"
                             (lambda (port) (read port)))
                           lingua)))
                 (symlink "guix.html"
                          (string-append #$output "/" tag "/index.html")))))
           (list #$@%linguas))))))

(computed-file "guix-web-site" build
               #:guile (specification->package "guile")
               #:options '(#:effective-version "3.0"))

;; Local Variables:
;; eval: (put 'let-package 'scheme-indent-function 1)
;; End:
