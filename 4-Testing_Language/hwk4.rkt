#!/usr/bin/racket
#lang racket

;; =========================================
;; || Michael Krebs and Christopher Myers ||
;; =========================================



;; ==============================
;; || LANGUAGE DATA STRUCTURES ||
;; ==============================


;; A question is (make-question string list[string])
(define-struct question (question answers))


;; A cmd is either
;; -a symbol,
;; -(make-PRINT-SECTION-RESULTS string)
;; -(make-PRINT string),
;; -(make-IF-RESULTS number string list[cmd] list[cmd]),	-- If the student's current grade <= IF-RESULTs, ctrue, else cfalse.
;; -(make-ASK-QUESTION question)
;; -(make-SECTION string list[cmd])


(define PRINT-EXAM-RESULTS 'per)


;; A PRINT-SECTION-RESULTS is (make-PRINT-SECTION-RESULTS string)
(define-struct PRINT-SECTION-RESULTS (section-name))


;; A PRINT is (make-PRINT string)
(define-struct PRINT (msg))				


;; A IF-RESULTS is (make-IF-RESULTS name list[cmd] list[cmd])
(define-struct IF-RESULTS (bounds section-name ctrue cfalse))    ;;the student's current score in specified section is compared to bounds. If less-or-equal to bounds, ctrue; else, cfalse.


;; A ASK-QUESTION is (make-ASK-QUESTION question)
(define-struct ASK-QUESTION (question))


;; A SECTION is (make-SECTION string list[cmd])
(define-struct SECTION (name cmds))


;; An exam is a list[cmd]



;; ===================
;; || EXAMPLE EXAMS ||
;; ===================


;; Student #1 Exam:
(define math-exam
  	(let 	([q1 (make-question "What is 3*4+2?" (list "14"))]
	  	 [q2 (make-question "What is 2+3*4?" (list "14"))]
		 [q3 (make-question "What is 5+2*6?" (list "17"))]
	 	 [q4 (make-question "What is 3+5*2?" (list "13"))]
		 [q5 (make-question "What is the reduced form of 12/18?: (1) 6/9  (2) 1/1.5  (3) 2/3" (list "3"))]
		 [q6 (make-question "What is 8+3*2" (list "14"))])
	  (list
	    	(make-SECTION "arithmetic" (list
					(make-ASK-QUESTION q1)
					(make-ASK-QUESTION q2)
					(make-ASK-QUESTION q3)
					(make-IF-RESULTS 50 "arithmetic"
							 	(list
								  	(make-PRINT "You seem to be having trouble with these. Try again.")
									(make-ASK-QUESTION q4))
								empty)))
		(make-SECTION "fractions" (list
					(make-ASK-QUESTION q5)))
		(make-SECTION "arithmetic"(list
                                        (make-IF-RESULTS 50 "arithmetic"
							 	(list
								  	 empty
									(make-ASK-QUESTION q6))
								empty)))
		(make-PRINT-SECTION-RESULTS "arithmetic")
		(make-PRINT-SECTION-RESULTS "fractions"))))
	  

;; WPI History Exam
(define exam-wpihistory
  	(let 	([q1 (make-question "When was WPI founded?" (list "1865"))]
		 [q2 (make-question "What is Gompei?" (list "goat"))]
		 [q3 (make-question "Who was the first president of WPI?: (1) Boynton, (2) Washburn, (3) Thompson" (list "3"))]
		 [q4 (make-question "Name one of the two towers behind a WPI education." (list "boynton" "wasburn" "lotr-orthanac"))])
	  (list									;;Dear HW grader, I hope you have a sense of humor!
		(make-ASK-QUESTION q1)
		(make-PRINT "Let's see if you know your WPI personalities.")
		(make-SECTION "personalities" (list
						(make-ASK-QUESTION q2)
						(make-ASK-QUESTION q3)
						(make-PRINT-SECTION-RESULTS "personalities")))
		(make-ASK-QUESTION q4)
		PRINT-EXAM-RESULTS
		(make-PRINT "There's some more WPI history on the web. And life."))))
