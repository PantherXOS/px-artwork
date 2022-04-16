#| GNU Guix manifest

This file is a GNU Guix manifest file. It can be used with GNU Guix to
create an environment to work on the project. |#

(use-modules (gnu packages))


(specifications->manifest
 (list "gimp"
       "guile"
       "guile-picture-language"
       "imagemagick"
       "inkscape"
       "racket"))
