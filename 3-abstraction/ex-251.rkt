#lang htdp/isl

(require test-engine/racket-tests)

; ### Constants

; ### Data Definitions

; ### Functions

; [List-of Number] -> Number
; computes the sum of 
; the numbers on l
(check-expect (sum '(1 2 3 4)) 10)
(define (sum l)
  (fold1 l + 0)
  )


; [List-of Number] -> Number
; computes the product of 
; the numbers on l
(check-expect (product '(1 2 3 4)) 24)
(define (product l)
  (fold1 l * 1)
  )


; [List-of Number] [Number Number -> Number] Number -> Number
(define (fold1 items fold-fn accumulator)
  (cond
    [(empty? items) accumulator]
    [else
      (fold1
        (rest items)
        fold-fn
        (fold-fn (first items) accumulator)
        )]))


(test)

