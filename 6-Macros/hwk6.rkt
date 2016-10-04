#!/usr/bin/racket

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
                (lambda (mparam ...) mfunc)] ...
	       [else
		 (error (format "Function name not defined: ~a~n" (symbol->string message)))])))]))
(define-syntax send
  (syntax-rules ()
    [(send obj funcname params ...)
     ((obj 'funcname) params ...)]))


(define dillo-class
  (class (initvars length dead?)
    (method longer-than? (len) (> length len))
    (method run-over () (dillo-class (+ length 1) true))))

(define zero-class    ; Demonstrates that a class with no methods and no
  (class (initvars))) ; vars still works flawlessly.

(define d3 (dillo-class 5 false)) 
(send d3 longer-than? 6)           ; f 
(send d3 longer-than? 5)           ; f
(define d4 (send d3 run-over))
(send d4 longer-than? 5)           ; t
;(send d3 run-dover) ; Generates error "Function not defined: run-dover"



;; ===========
;; | PART II |
;; ===========


(define-syntax policy-checker
  (syntax-rules ()
    [(policy-checker
      (job (perms ...) (objs ...)) ...)

     (lambda (sbjname rqprm rqobj)
       (or (and (symbol=? sbjname 'job)
              (and (cons? (member rqprm (list 'perms ...)))
                   (cons? (member rqobj (list 'objs ...)))))...))]))


(define check-policy
  (policy-checker
   (programmer (read write) (code documentation))
   (tester (read) (code))
   (tester (write) (documentation))
   (manager (read write) (reports))
   (manager (read) (documentation))
   (ceo (read write) (code documentation reports))))

(check-policy 'programmer 'write 'code)    ; t
(check-policy 'programmer 'read 'reports)  ; f
(check-policy 'tester 'read 'code)         ; t
(check-policy 'tester 'write 'code)        ; f
(check-policy 'ceo 'write 'code)           ; t