#!/usr/bin/racket
#lang racket				;; These three lines are required to run the program without DrRacket
(require test-engine/racket-tests)
				

;; patch, contains data needed to apply an patch
;; opcode, symbol (`ADD, 'DEL); str, string; pos1, number; pos2, number.
;; Intended to be used in the apply-patch function.
(define-struct patch (opcode pos str len))

;; Examples:
(define del-patch (make-patch 'DEL 0 "" 3))
(define add-patch (make-patch 'ADD 4 "quick " 5))


;; apply-patch: patch string -> string
;; Consumes an patch (above) and a string, returns a patched string
(check-expect (apply-patch del-patch "The quick brown fox") " quick brown fox")
(check-expect (apply-patch add-patch "The brown fox") "The quick brown fox")
(define (apply-patch patch str)
	(cond
		[(symbol=? 'ADD (patch-opcode patch))
			(insert (patch-pos patch) str (patch-str patch))]
		[(symbol=? 'DEL (patch-opcode patch))
			(delete (patch-pos patch) (patch-len patch) str)]))


;; Delete: number number string -> string
;; Consumes a starting position, an amount to delete and the string to delete from
;; Produces a string with specified deleted portion via starting position and deleted amount
(check-expect (delete 2 2 "apples") "apes")
(check-expect (delete 1 5 "0123456") "06")
(define (delete position num str)
	(string-append (substring str 0 position) (substring str (+ position num))))


;; number string string -> string
;; Consumes a position, a string, and a substring. Inserts a substring at a position in the string.
(check-expect (insert 4 "The fox" "quick brown " ) "The quick brown fox")
(define (insert position str substr)
	(string-append 
	(substring str 0 position)
	substr
	(substring str position (string-length str))))

(test) ;; Run check-expect tests. Not needed if DrRacket is configured right.
