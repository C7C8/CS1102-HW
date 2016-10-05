#!/usr/bin/racket

;; Michael Krebs and Christopher Myers


;; ==========
;; | PART I |
;; ==========
(printf "Dillo Macro\n")

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

(printf "Policy Macro\n")

;; ===========
;; | PART II |
;; ===========


(define-syntax policy-checker
  (syntax-rules ()
    [(policy-checker
      (job (perms ...) (objs ...)) ...)
;; need to get all acceptable inputs, if any incorrect error message informing
     (lambda (sbjname rqprm rqobj)
       (let([job-list (list 'job ...)]
            [perm-list (list 'perms ... ...)]
            [obj-list (list  'objs ... ...)])
            (cond[(not(cons? (member sbjname job-list)))
                  (error (format"\'~a\' is not defined in policy" sbjname))]
                 [(not(cons? (member rqprm perm-list)))
                  (error (format"\'~a\' is not defined in policy" rqprm))]
                 [(not(cons? (member rqobj obj-list)))
                  (error (format"\'~a\' is not defined in policy" rqobj))]))
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

;;
;; Below are Error causing cases
;;

;;(check-policy 'ceo 'wite 'code)            ; error 'wite' is not defined in policy
;;(check-policy 'c3po 'write 'code)          ; error 'c3po' is not defined in policy
;;(check-policy 'ceo 'write 'food)             ; error 'food' is not defined in policy