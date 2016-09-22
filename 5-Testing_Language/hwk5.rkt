#!/usr/bin/racket
#lang racket

;; =========================================
;; || Michael Krebs and Christopher Myers ||
;; =========================================



;; ==============================
;; || LANGUAGE DATA STRUCTURES ||
;; ==============================


;; A question is (make-question string string number)
;; "Limit" is the minimum percentage needed for the student to be
;; asked this question.
(define-struct question (question answer))


;; A cmd is either
;; -a symbol,
;; -(make-PRINT-SECTION-RESULTS string)
;; -(make-PRINT string),
;; -(make-IF-RESULTS number list[cmd] list[cmd]),
;; -(make-ASK-QUESTION question)
;; -(make-SECTION string list[cmd])
(define-struct PRINT-SECTION-RESULTS (section-name))
(define PRINT-EXAM-RESULTS 'per)
(define-struct PRINT (msg))				
(define-struct IF-RESULTS (bounds ctrue cfalse))	;;the student's current score is compared to bounds. If less-or-equal to bounds, ctrue; else, cfalse.
(define-struct ASK-QUESTION (question))
(define-struct SECTION (name cmds))


;; An exam is a list[cmd]



;; ===================
;; || EXAMPLE EXAMS ||
;; ===================


;; Student #1 Exam:
(define exam-s1
  	(let 	([q1 (make-question "What is 3*4+2?" "14")]
	  	 [q2 (make-question "What is 2+3*4?" "14")]
		 [q3 (make-question "What is 5+2*6?" "17")]
	 	 [q4 (make-question "What is 3+5*2?" "13")]
		 [q5 (make-question "What is the reduced form of 12/18?: (1) 6/9  (2) 1/1.5  (3) 2/3" "3")]
		 [q6 (make-question "What is 8+3*2" "14")])
	  (list
	    	(make-SECTION "arithmetic" (list
					(make-ASK-QUESTION q1)
					(make-ASK-QUESTION q2)
					(make-ASK-QUESTION q3)
					(make-IF-RESULTS 50
							 	(list
								  	(make-PRINT "You seem to be having trouble with these. Try again.")
									(make-ASK-QUESTION q4))
								empty)))
		(make-SECTION "fractions" (list
					(make-ASK-QUESTION q5)))
		(make-SECTION "arithmetic" (list
					(make-ASK-QUESTION q6)))
		(make-PRINT-SECTION-RESULTS "arithmetic")
		(make-PRINT-SECTION-RESULTS "fractions"))))
	  

