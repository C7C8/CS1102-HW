#!/usr/bin/racket
#lang racket

;; =========================================
;; || Michael Krebs and Christopher Myers ||
;; =========================================


;; A question is (make-question string string number)
;; "Limit" is the minimum percentage needed for the student to be
;; asked this question.
(define-struct question (question answer limit))


;; A section is (make-section string list[question])
(define-struct section (name questions))


;; A cmd is either
;; -a symbol,
;; -(make-PRINT string),
;; -(make-IF-RESULTS number cmd cmd),
;; -(make-GIVE-SECTION list[section])
;; -(make-NOP)						;;No-Operation -- Only used for empty cases in IF statements.
(define PRINT-SECTION-RESULTS 	'psr)
(define PRINT-EXAM-RESULTS 	'per)
(define-struct PRINT (msg))				
(define-struct IF-RESULTS (bounds ctrue cfalse))	;;the student's current score is compared to bounds. If less than bounds, ctrue; else, cfalse.
(define-struct GIVE-SECTION questions)
(define-struct NOP)


;; An exam is a list[cmd]

