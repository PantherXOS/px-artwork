;;; Trigon pattern generator.
(use-modules (pict))


;;; CONSTANTS
(define BG_COLOR "#232323")  ; Carbon
(define PALETTE
  ;; Ukiyo-e terra.
  (list "#A6EBEB"        ; Blue
        "#DC6130"        ; Red
        "#FFCF19"        ; Yellow
        "#FFFDD7"        ; Light
        "#A17F66"        ; Dark
        "transparent")) ; Transparent
(define TRIGON_SIDE 24)  ; side width
(define EMPTY_IMAGE (rectangle 0 0))


;;; PROCEDURES
(define* (pattern w h)
  "Return a trigon pattern W trigons width and H trigons height."
  (cond [(= h 0) EMPTY_IMAGE]
        [else
         (pin-under
          (row w #:direction (if (odd? h) -1 1))
          0                  ; x offset
          (/ TRIGON_SIDE 2)  ; y offset
          (pattern w (- h 1)))]))

(define* (row n #:key (direction -1))
  "Return a row of N trigons alternating between left and right
   direction according to the initial DIRECTION."
  (cond [(= n 0) EMPTY_IMAGE]
        [else
         (hc-append
          (rotate (trigon TRIGON_SIDE) (* 90 direction))
          (row (- n 1) #:direction (* -1 direction)))]))

(define (trigon side)
  "Return a randomly colored equilateral triangle pointing upwards."
  (let* [(height (trigon-height side))
         (color (list-ref PALETTE (random (length PALETTE))))
         (base-trigon (colorize (triangle side height #:border-width 0.5)
                                BG_COLOR))]

    (if (string=? "transparent" color)
        (cellophane base-trigon 0)
        (fill base-trigon color))))

(define (trigon-height side)
  "Return the height of an equilateral triangle of SIDE pixels."
  (* side (/ (sqrt 3) 2)))


;;; RUN IT.
(pict->file (pattern 18 6) "/tmp/pict-trigon-pattern-YEARS.svg")
(set! TRIGON_SIDE (* 2 TRIGON_SIDE))
(pict->file (pattern 9 9) "/tmp/pict-trigon-pattern-10.svg")

;; FIXME: The color pattern does not vary on every execution.
;; FIXME: The generated SVG is impossible to edit in Inkscape.
;; I'll see what happens in Racket (it works).
