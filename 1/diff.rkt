#!/usr/bin/racket
#lang racket				;; These three lines are required to run the program without DrRacket
(require test-engine/racket-tests)

;;THERE ARE MORE LINES OF ***COMMENTS*** HERE THAN THERE ARE LINES OF CODE!

;; A delete is (make-delete number)
(define-struct delete (len))
;; Template:
; (define (delete-func a-delete)
;	...(delete-len a-delete)
; )
;; Example:
(define delete-ex (make-delete 6))


;; An insert is (make-insert string)
(define-struct insert (str))
;; Template:
; (define (insert-func an-insert)
;	...(insert-str an-insert)
; )
;; Example: 
(define insert-ex (make-insert " lazy"))


;; An operation is either 
;; -An insert, or
;; -a delete
;;
;; Template:
; (define (operation-func an-op)
; 	(cond [(insert? an-op) (insert-func an-op)]
;		[(delete? an-op) (delete-func an-op)]))


;; A patch is (make-patch operation number)
(define-struct patch (op pos))
;; Template:
; (define (patch-func a-patch)
;	...(patch-op a-patch)...
;	...(patch-pos a-patch)...
; )
;; Examples:
(define patch-ins-ex (make-patch insert-ex 10))  ;; Patch insert example
(define patch-del-ex (make-patch delete-ex 13))	;; Patch delete example


;; apply-patch: patch string -> string
;; Consumes an patch and a string, returns a patched string
;; Test cases (see above defines for patches)
(check-expect (apply-patch patch-ins-ex "We are not programmers.") "We are not lazy programmers.")
(check-expect (apply-patch patch-del-ex "I don't have other example sentences.") "I don't have example sentences.")
(define (apply-patch patch str)
	(apply-op (patch-op patch) (patch-pos patch) str)) ;;honestly I'm not sure why this function exists


;; apply-op: operation number string -> string
;; Consumes an operation, a number, and a string. Applies the operation
;; at the given position on string str, returning the results.
(check-expect (apply-op delete-ex 4 "The quick brown fox") "The brown fox")
(check-expect (apply-op insert-ex 14 "jumps over the dog.") "jumps over the lazy dog.")
(define (apply-op op position str)
	(cond 
		[(delete? op)
			(str-delete position (delete-len op) str)]
		[(insert? op)
			(str-insert position str (insert-str op))]))
			

;; Delete: number number string -> string
;; Consumes a starting position, an amount to delete and the string to delete from
;; Produces a string with specified deleted portion via starting position and deleted amount
(check-expect (str-delete 2 2 "apples") "apes")
(check-expect (str-delete 1 5 "0123456") "06")
(define (str-delete position num str)
	(string-append (substring str 0 position) (substring str (+ position num))))


;; number string string -> string
;; Consumes a position, a string, and a substring. Inserts substr at position in str, returning the result.
(check-expect (str-insert 4 "The fox" "quick brown " ) "The quick brown fox")
(check-expect (str-insert 14 "jumps over the dog." " lazy") "jumps over the lazy dog.")
(define (str-insert position str substr)
	(string-append 
	(substring str 0 position)
	substr
	(substring str position (string-length str))))

(test) ;; Run check-expect tests. Not needed if DrRacket is configured in "Beginning Student" mode.

