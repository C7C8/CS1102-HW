#!/usr/bin/racket
(require test-engine/racket-tests)

;; Michael Krebs and Christopher Myers



;; ==========
;; | PART I |
;; ==========


(define-syntax class
  (syntax-rules ()
    [(class (initvars var ...)
       (method mname (mparam ...) mfunc) ... )
     (lambda (var ...)
       (lambda (message)
         (cond [(symbol=? message 'mname) ; M'Function *tips parameter*
                (lambda (mparam ...) mfunc)] ...)))]))
(define-syntax send
  (syntax-rules ()
    [(send obj funcname params ...)
     ((obj 'funcname) params ...)]))


(define dillo-class
  (class (initvars length dead?)
    (method longer-than? (len) (> length len))
    (method run-over () (dillo-class (+ length 1) true))))

(define d3 (dillo-class 5 false))
(send d3 longer-than? 6)
(send d3 longer-than? 5)
(define d4 (send d3 run-over))
(send d4 longer-than? 5)

 