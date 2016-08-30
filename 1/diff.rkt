#!/usr/bin/racket
#lang racket


; Operation, contains data about... well, an operation!
; opcode, symbol; position, number; data, string
(define-struct operation (opcode position data))

; apply-op, takes an op and produces a patched string
; op -> string
; TODO: Test cases
;(define (apply-op op str)
;	()) ; TODO: Implement

;;Delete: number number string -> string
;;Consumes a starting position, an amount to delete and the string to delete from
;;Produces a string with specified deleted portion via starting position and deleted amount
(check-expect (delete 2 2 "apples") "apes")
(check-expect (delete 1 5 "0123456") "06")
(define (delete position num str)
	(string-append (substring str 0 position) (substring str (+ position num))))

; insert, inserts a substring at a position
; number string string -> string
(check-expect (insert 4 "The fox" "quick brown " ) "The quick brown fox") ; Can't use these with DrRacket; commented for now
(define (insert position str patch)
	(string-append 
	(substring str 0 position) 						; part 1: get the first half
	patch									; part 2: just tack on the inserted part
	(substring str position (string-length str))))				; part 3: (tricky part) tack on the end of the string

