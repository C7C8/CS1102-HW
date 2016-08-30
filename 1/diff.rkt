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


; insert, inserts a substring at a position
; number string string -> string
(check-expect (insert 4 "The fox" "quick brown " ) "The quick brown fox") ; Can't use these with DrRacket; commented for now
(define (insert position str patch)
	(string-append 
	(substring str 0 position) 						; part 1: get the first half
	patch									; part 2: just tack on the inserted part
	(substring str position (string-length str))))				; part 3: (tricky part) tack on the end of the string

