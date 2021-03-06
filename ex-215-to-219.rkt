#lang htdp/bsl

(require 2htdp/image)
(require 2htdp/universe)
(require test-engine/racket-tests)

; NOTE: when an exercise modifies a previously existing function,
; a new version name will be used, like *-v2

; ==================== Exercise 215 ====================
; ### Constants
(define X-BLOCKS 30)
(define Y-BLOCKS 20)
(define BLOCK-WIDTH 10)
(define BACKGROUND-WIDTH (* BLOCK-WIDTH X-BLOCKS))
(define BACKGROUND-HEIGHT (* BLOCK-WIDTH Y-BLOCKS))
(define BACKGROUND (empty-scene BACKGROUND-WIDTH BACKGROUND-HEIGHT))
(define SNAKE-COLOUR "red")
(define FOOD-COLOUR "green")


; The prefixes are there to avoid clashes with an import
(define d-up "up")
(define d-down "down")
(define d-left "left")
(define d-right "right")

; ### Data Definitions
; A Direction is one of:
; - d-up
; - d-down
; - d-left
; - d-right
(define DIRECTIONS (list d-up d-down d-left d-right))


; WorldState is a structure (make-world Direction Posn)
; Interpretation: the snake is in pos and moves to direct

; NOTE: The pos is a logical position: how many units instead of
; pixels. This allows for simpler/abstracter thinking, and makes
; things like re-escaling just a breeze.
(define-struct world [pos direct])


; ### Functions
; WorldState -> Image
(define (render-world ws)
  (render-element 
    (world-pos ws)
    SNAKE-COLOUR
    BACKGROUND
    ))


(define (render-element pos col img)
  (underlay/xy
    img
    (* (posn-x pos) BLOCK-WIDTH)
    (* (posn-y pos) BLOCK-WIDTH)
    (square  ; Squares look more retro =)
      (sub1 BLOCK-WIDTH)  ; 1px gives some olc lcd feeling 
      "solid" 
      col
      )))


; WorldState KeyEvent -> WorldState
; handles the key events
(define (on-key-press ws ke)
  (make-world
    (world-pos ws)
    (calculate-new-direction (world-direct ws) ke)
      ))


; Direction KeyEvent -> Direction
; Given the current direction and a ke event, returns the resulting direction
(check-expect (calculate-new-direction d-down d-down) d-down)
(check-expect (calculate-new-direction d-left d-down) d-down)
(check-expect (calculate-new-direction d-up d-down) d-up)
(define (calculate-new-direction current-dir ke)
  (cond
    [(and (string=? ke d-up) (not (string=? current-dir d-down))) d-up]
    [(and (string=? ke d-down) (not (string=? current-dir d-up))) d-down]
    [(and (string=? ke d-left) (not (string=? current-dir d-right))) d-left]
    [(and (string=? ke d-right) (not (string=? current-dir d-left))) d-right]
    [else current-dir]
    ))


; WorldState KeyEvent -> WorldState
; handles the ticking of the world
(define (tock ws)
  (make-world
    (translate-pos (world-pos ws) (world-direct ws))
    (world-direct ws)
    ))


; Posn Direction -> Posn
; Translates the pos one unit according to the direction
(define (translate-pos pos dir)
  (cond
    [(string=? dir d-up) (make-posn (posn-x pos) (- (posn-y pos) 1))]
    [(string=? dir d-down) (make-posn (posn-x pos) (+ (posn-y pos) 1))]
    [(string=? dir d-left) (make-posn (- (posn-x pos) 1) (posn-y pos))]
    [(string=? dir d-right) (make-posn (+ (posn-x pos) 1) (posn-y pos))]
    ))


(define (main ws)
  (big-bang 
    ws
    [to-draw render-world]
    [on-key on-key-press]
    [on-tick tock 0.1]
    ))


; (main (make-world (make-posn 0 0) "down"))

; =================== End of exercise ==================




; ==================== Exercise 216 ====================
; suffix for new versions: -v2

; ### Functions
; WorldState -> Boolean
(define (over? ws)
  (hitting-wall? (world-pos ws) (world-direct ws))
  )


; Posn Direction -> Boolean
; Returns whether the posn is hitting a wall on the next tick
(define (hitting-wall? pos dir)
  (or
    (and 
      (zero? (posn-x pos)) 
      (string=? dir d-left)
      )
    (and 
      (= (posn-x pos) (sub1 X-BLOCKS))
      (string=? dir d-right)
      )
    (and 
      (zero? (posn-y pos))
      (string=? dir d-up)
      )
    (and 
      (= (posn-y pos) (sub1 Y-BLOCKS))
      (string=? dir d-down)
      )))


; WorldState -> Image
; renders the last image after the world ended
(define (render-final ws)
  (overlay/align
    "left"
    "bottom"
    (render-world ws)
    (make-message "Bro, you hit the wall!")
    ))


; String -> Image
(define (make-message msg)
  (text msg 24 "black")
  )


(define (main-v2 ws)
  (big-bang 
    ws
    [to-draw render-world]
    [on-key on-key-press]
    [on-tick tock 0.1]
    [stop-when over? render-final]
    ))


; (main-v2 (make-world (make-posn 0 0) "down"))

; =================== End of exercise ==================




; ==================== Exercise 217 ====================
; suffix for new versions: -v3

; ### Data Definitions
; Trail is one of:
; - (cons Posn '())
; - (cons Posn Trail)
; Interpretation: non empty list of Posns that represent
; all the positions the snake is using


; WorldState is a structure (make-world Direction Trail)
; Interpretation: the snake is placed in trail 
; and moves to direct
(define-struct world-v3 [trail direct])


(define (render-world-v3 ws)
  (render-trail
    (world-v3-trail ws)
    BACKGROUND
    ))


; Trail Image -> Image
(define (render-trail trail img)
  (cond
    [(empty? trail) img]
    [else
      (render-trail 
        (rest trail) 
        (render-element (first trail) SNAKE-COLOUR img)
        )]))


; WorldState KeyEvent -> WorldState
; handles the ticking of the world
(define (tock-v3 ws)
  (make-world-v3
    (move-trail (world-v3-trail ws) (world-v3-direct ws))
    (world-v3-direct ws)
    ))


; Trail Direction -> Trail
; Moves the trail one unit in the passed direction
(check-expect 
  (move-trail (list (make-posn 10 0) (make-posn 9 0)) "down")
  (list (make-posn 10 1) (make-posn 10 0))
  )
(define (move-trail trail direction)
  (cons 
    (translate-pos (first trail) direction)
    (drop-last trail)
    ))


; Non-empty-list-of-anything -> Anything
; Returns the last element of a non empty list
(check-expect (last (list 1 2 3)) 3)
(check-expect (last (list 1)) 1)
(define (last loa)
  (cond
    [(empty? (rest loa)) (first loa)]
    [else (last (rest loa))]
    ))


; Non-empty-list-of-anything -> List-of-anything
; Drops the last element of a non empty list loa
(check-expect (drop-last (list 1 2 3)) (list 1 2))
(define (drop-last loa)
  (cond
    [(empty? (rest loa)) '()]
    [else
      (cons
        (first loa)
        (drop-last (rest loa))
        )]))


; WorldState KeyEvent -> WorldState
; handles the key events
(define (on-key-press-v3 ws ke)
  (make-world-v3
    (world-v3-trail ws)
    (cond
      [(member ke DIRECTIONS) ke]
      [else (world-v3-direct ws)]
      )))


(define (main-v3 ws)
  (big-bang 
    ws
    [to-draw render-world-v3]
    [on-key on-key-press-v3]
    [on-tick tock-v3 0.1]
    ))

; (main-v3 (make-world-v3 (list (make-posn 2 0) (make-posn 1 0) (make-posn 0 0)) "down"))

; =================== End of exercise ==================




; ==================== Exercise 218 ====================
; suffix for new versions: -v4

; ### Constants
(define running "running")
(define hit-wall "hit-wall")
(define hit-itself "hit-itself")

; ### Data Definitions
; GameStatus is one of:
; - running
; - hit-wall
; - hit-itself


; WorldState is a structure (make-world Direction Trail GameStatus)
; Interpretation: the snake is placed in trail 
; and moves to direct
(define-struct world-v4 [trail direct status])


; WorldState -> Boolean
(define (over?-v4 ws)
  (not (string=? (world-v4-status ws) running))
  )


; WorldState KeyEvent -> WorldState
; Handles the key events
(define (on-key-press-v4 ws ke)
  (make-world-v4
    (world-v4-trail ws)
    (calculate-new-direction (world-v4-direct ws) ke)
    (world-v4-status ws)
    ))


; WorldState KeyEvent -> WorldState
; Handles the ticking of the world
(define (tock-v4 ws)
  (cond
    [(hitting-wall? (first (world-v4-trail ws)) (world-v4-direct ws)) 
     (make-world-v4
        (world-v4-trail ws)
        (world-v4-direct ws)
        hit-wall
        )]

    [(hitting-itself? (world-v4-trail ws) (world-v4-direct ws))
     (make-world-v4
        (world-v4-trail ws)
        (world-v4-direct ws)
        hit-itself
        )]

    [else
      (make-world-v4
        (move-trail (world-v4-trail ws) (world-v4-direct ws))
        (world-v4-direct ws)
        (world-v4-status ws)
        )]))

; Trail Direction -> Boolean
; Returns whether the trail is hitting itself on the next tick
(define (hitting-itself? trail direction)
  (member 
    (translate-pos (first trail) direction)
    (drop-last (rest trail))
    ))


; WorldState -> Image
(define (render-world-v4 ws)
  (render-trail
    (world-v4-trail ws)
    BACKGROUND
    ))


; WorldState -> Image
; renders the last image after the world ended
(define (render-final-v4 ws)
  (overlay/align
    "left"
    "bottom"
    (make-message
      (cond
        [(string=? (world-v4-status ws) hit-wall) "Ha-ha you hit the wall!"]
        [(string=? (world-v4-status ws) hit-itself) "Ha-ha you hit yourself!"]
        ))
    (render-world-v4 ws)
    ))


(define (main-v4 ws)
  (big-bang 
    ws
    [to-draw render-world-v4]
    [on-key on-key-press-v4]
    [on-tick tock-v4 0.1]
    [stop-when over?-v4 render-final-v4]
    ))


; (main-v4
; (make-world-v4 
;   (list 
;     (make-posn 4 0)
;     (make-posn 3 0) 
;     (make-posn 2 0) 
;     (make-posn 1 0) 
;     (make-posn 0 0)) 
;   "down"
;   running
;   ))

; =================== End of exercise ==================




; ==================== Exercise 219 ====================
; suffix for new versions: -v5

; Food is a Posn
; Interpretation: the position where the food is at given moment

; WorldState is a structure:
;   (make-world Trail Direction GameStatus Food)
; Interpretation: the snake is placed in trail 
; and moves to direct
(define-struct world-v5 [trail direct status food])


; WorldState KeyEvent -> WorldState
; Handles the ticking of the world
(define (tock-v5 ws)
  (cond
    [(hitting-wall? (first (world-v5-trail ws)) (world-v5-direct ws)) 
     (make-world-v5
        (world-v5-trail ws)
        (world-v5-direct ws)
        hit-wall
        (world-v5-food ws)
        )]

    [(hitting-itself? (world-v5-trail ws) (world-v5-direct ws))
     (make-world-v5
        (world-v5-trail ws)
        (world-v5-direct ws)
        hit-itself
        (world-v5-food ws)
        )]

    [(hitting-food? (world-v5-trail ws) (world-v5-direct ws) (world-v5-food ws))
     (make-world-v5
        (cons 
          (translate-pos (first (world-v5-trail ws)) (world-v5-direct ws)) 
          (world-v5-trail ws)
          )
        (world-v5-direct ws)
        (world-v5-status ws)

        (create-food
          (translate-pos 
            (first (world-v5-trail ws)) 
            (world-v5-direct ws)
            )))]

    [else
      (make-world-v5
        (move-trail (world-v5-trail ws) (world-v5-direct ws))
        (world-v5-direct ws)
        (world-v5-status ws)
        (world-v5-food ws)
        )]))


; Trail Food -> Boolean
; Returns whether the snake is hitting the food with the head in the next tick
(define (hitting-food? trail direction food)
  (equal?
    (translate-pos (first trail) direction)
    food
    ))


; Posn -> Posn
; Returns the new position where the food can be placed, but not in not-here
(define (create-food not-here)
  (check-create-food 
    (make-posn (random X-BLOCKS) (random Y-BLOCKS))
    not-here 
    ))


; Posn Posn -> Posn
; If candidate and not-here do not collide, food is returned, otherwise
; another candidate is requested
(define (check-create-food candidate not-here)
  (if
    (equal? candidate not-here)
    (create-food not-here)
    candidate
    ))


; WorldState -> Image
(define (render-world-v5 ws)
  (render-element 
    (world-v5-food ws) 
    FOOD-COLOUR 
    (render-trail
      (world-v5-trail ws)
      BACKGROUND
      )))


; WorldState -> Image
; renders the last image after the world ended
(define (render-final-v5 ws)
  (overlay/align
    "left"
    "bottom"
    (make-message
      (cond
        [(string=? (world-v5-status ws) hit-wall) "Ha-ha you hit the wall!"]
        [(string=? (world-v5-status ws) hit-itself) "Ha-ha you hit yourself!"]
        ))
    (render-world-v5 ws)
    ))


; WorldState KeyEvent -> WorldState
; Handles the key events
(define (on-key-press-v5 ws ke)
  (make-world-v5
    (world-v5-trail ws)
    (calculate-new-direction (world-v5-direct ws) ke)
    (world-v5-status ws)
    (world-v5-food ws)
    ))


; WorldState -> Boolean
(define (over?-v5 ws)
  (not (string=? (world-v5-status ws) running))
  )


(define (main-v5 ws)
  (big-bang 
    ws
    [to-draw render-world-v5]
    [on-key on-key-press-v5]
    [on-tick tock-v5 0.1]
    [stop-when over?-v5 render-final-v5]
    ))


; (main-v5
;   (make-world-v5 
;     (list 
;       (make-posn 4 0)
;       (make-posn 3 0) 
;       (make-posn 2 0) 
;       (make-posn 1 0) 
;       (make-posn 0 0)) 
;     "down"
;     running
;     (make-posn 20 15)
;     ))

; =================== End of exercise ==================


; ============= Exercise 219 - extensions===============
; suffix for new versions: -v6
; Improvements/extensions of the exercise 219

; Food is a Posn
; Interpretation: the position where the food is at given moment

; DirectionRequest is one of:
; - Direction
; - #false
; Interpretation: direction requested for next world tick

; WorldState is a structure:
;   (make-world Trail Direction DirectionRequest GameStatus Food)
; 
; Interpretation: 
; - trail: the space the snake is taking. First element is the head
; - direct: direction the snake is currently moving
; - req-dir: requested direction for next tick
; - status: status of game
; - food: position of food
(define-struct world-v6 [trail direct req-dir status food])


; WorldState KeyEvent -> WorldState
; Handles the ticking of the world
(define (tock-v6 ws)
  (tick-world 
    ws 
    (world-v6-trail ws) 
    (first (world-v6-trail ws)) 
    (world-v6-direct ws) 
    (calculate-new-direction-v6 (world-v6-direct ws) (world-v6-req-dir ws))
    (world-v6-status ws)
    (world-v6-food ws)
    ))


; WorldState Trail Posn Direction Direction Status Food -> WorldState
; Same as tock-v6, but here all the necessary values are bound to a variable,
; thus avoiding huge amounts of repetition
(define (tick-world ws trail head direction next-direction status food)
  (cond
    [(hitting-wall? head next-direction) (set-world-status ws hit-wall)]
    [(hitting-itself? trail next-direction) (set-world-status ws hit-itself)]
    [(hitting-food?  trail next-direction food)
     (make-world-v6
        (cons (translate-pos head next-direction) trail)
        direction
        next-direction
        status
        (create-food (translate-pos head direction))
        )]

    [else
      (make-world-v6
        (move-trail trail next-direction)
        next-direction
        #false
        status
        food
        )]))


; WorldState -> WorldState
; Creates a copy of ws setting a new status
(define (set-world-status ws status)
  (make-world-v6
    (world-v6-trail ws)
    (world-v6-direct ws)
    (world-v6-req-dir ws)
    status
    (world-v6-food ws)
    ))


; Direction DirectionRequest -> Direction
; Calculates the new direction from current and request 
(check-expect (calculate-new-direction-v6 d-down d-down) d-down)
(check-expect (calculate-new-direction-v6 d-left d-down) d-down)
(check-expect (calculate-new-direction-v6 d-up d-down) d-up)
(check-expect (calculate-new-direction-v6 d-up #false) d-up)
(define (calculate-new-direction-v6 current-dir dir-req)
  (cond
    [(false? dir-req) current-dir]
    [(and (string=? dir-req d-up) (not (string=? current-dir d-down))) d-up]
    [(and (string=? dir-req d-down) (not (string=? current-dir d-up))) d-down]
    [(and (string=? dir-req d-left) (not (string=? current-dir d-right))) d-left]
    [(and (string=? dir-req d-right) (not (string=? current-dir d-left))) d-right]
    [else current-dir]
    ))


; WorldState -> Image
(define (render-world-v6 ws)
  (render-element 
    (world-v6-food ws) 
    FOOD-COLOUR 
    (render-trail
      (world-v6-trail ws)
      (above/align
        d-right
        BACKGROUND
        (make-score (calculate-points ws))
        ))))


; WorldState -> Image
; renders the last image after the world ended
(define (render-final-v6 ws)
  (overlay
    (make-message
      (cond
        [(string=? (world-v6-status ws) hit-wall) "Ha-ha you hit the wall!"]
        [(string=? (world-v6-status ws) hit-itself) "Ha-ha you hit yourself!"]
        ))
    (render-world-v6 ws)
    ))


; WorldState KeyEvent -> WorldState
; Handles the key events
(define (on-key-press-v6 ws ke)
  (make-world-v6
    (world-v6-trail ws)
    (world-v6-direct ws)

    ; NOTE: if the direction is changed directly here, weird bugs happen
    ; because sometimes you hit the keys so fast that the direction is changed
    ; multiple times within the same tick-period, leading to false positive
    ; crash detection. The better approach is to save the last key event, and 
    ; process it on the next tick
    (if (member ke DIRECTIONS) ke #false)

    (world-v6-status ws)
    (world-v6-food ws)
    ))


; WorldState -> Boolean
(define (over?-v6 ws)
  (not (string=? (world-v6-status ws) running))
  )


; Number -> Image
; Makes an image with the score
(define (make-score s)
  (text (format "score: ~a" s) 16 "black")
  )


; WorldState -> WorldState
(define (main-v6 ws)
  (calculate-points
    (big-bang 
      ws
      [to-draw render-world-v6]
      [on-key on-key-press-v6]
      [on-tick tock-v6 0.1]
      [stop-when over?-v6 render-final-v6]
      )))


; WorldState -> Number
; Returns the points accumulated in the game state
(define (calculate-points ws)
  (- (length (world-v6-trail ws)) (length INITIAL-SNAKE))
  )


(define 
  INITIAL-SNAKE
  (list 
    (make-posn 4 0)
    (make-posn 3 0) 
    (make-posn 2 0) 
    (make-posn 1 0) 
    (make-posn 0 0)
    )) 

(main-v6
  (make-world-v6 
    INITIAL-SNAKE
    "down"
    #false
    running
    (make-posn 20 15)
    ))

; =================== End of exercise ==================

(test)

