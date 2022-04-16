;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname trigon-pattern) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;;; Trigon pattern.
(require 2htdp/image)


;;; CONSTANTS
(define BG_COLOR (make-color 35 35 35))  ; Carbon
(define PALETTE
  ;; Primary.
  #;
  (list (make-color 102 209 255)  ; Blue
        (make-color 255 139 102)  ; Red
        (make-color 255 238 102)  ; Yellow
        (make-color 90 79 106)    ; Dark
        (make-color 229 229 229)  ; Light
        (make-color 0 0 0 0))     ; Transparent black
  ;; Ukiyo-e terra.
  (list (make-color 166 237 237)  ; Blue
        (make-color 220 98 49)    ; Red
        (make-color 255 209 28)   ; Yellow
        (make-color 255 253 216)  ; Light
        (make-color 162 128 103)  ; Dark        
        (make-color 0 0 0 0))     ; Transparent black
  )    

(define TRIGON_SIDE 24)  ; side width

;;; HELPER FUNCTIONS
(define (pattern w h)
  ;; Return a trigon pattern W trigons width and H trigons height.
  (cond [(= h 0) empty-image]
        [else           
         (overlay/xy
          (row w (if (odd? h) -1 1))
          0                  ; x offset
          (/ TRIGON_SIDE 2)  ; y offset
          (pattern w (- h 1)))]))

(define (row n direction)
  ;; Return a row of N triangles alternating between left and right
  ;; direction according to the initial DIRECTION.
  (cond [(= n 0) empty-image]
        [else
         (beside
          (rotate (* 90 direction) (trigon TRIGON_SIDE))
          (row (- n 1) (* -1 direction)))]))

(define (trigon side)
  ;; Return a randomly colored equilateral triangle pointing upwards.
  ;; FIXME: Pass color as an argument to make this function pure.
  (let [(color (list-ref PALETTE (random (length PALETTE))))]
    
    (triangle side "solid" color)))


;;; RUN IT.

;;; Pattern for YEARS.
(save-svg-image (pattern 18 6) "/tmp/trigon-pattern-YEARS.svg")

;;; Pattern for 10.
(set! TRIGON_SIDE (* 2 TRIGON_SIDE))
(save-svg-image (pattern 9 9) "/tmp/trigon-pattern-10.svg")

;; FIXME: When generating trigons with fill and stroke, the trigons are
;; not uniform (many have gaps between fill and stroke).
;;
;; I'm currently generating the fill only and then giving all trigons a
;; stroke in Inkscape.