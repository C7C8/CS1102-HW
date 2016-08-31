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
			

;; overlap? patch patch -> boolean
;; Consumes two patches and returns a boolean whose value depends on whether there's an overlap or not
;; Overlaps are defined as 
;; 1. Two insertions that start at the same location, 
;; 2. Two deletions whose ranges overlap,
;; 3. An insertion that starts within the range of a deletion (unless they start at the same location.
(check-expect (overlap? patch-ins-ex patch-ins-ex) #T)
(check-expect (overlap? patch-del-ex patch-del-ex) #T)
(check-expect (overlap? patch-del-ex patch-ins-ex) #F)
(define (overlap? patch1 patch2) 
	(cond
		[(and (delete? (patch-op patch1)) (delete? (patch-op patch2))) 
			(delete-overlap? patch1 patch2)]
		[(and (insert? (patch-op patch1)) (insert? (patch-op patch2)))
			(insert-overlap? patch1 patch2)]
		[else
			(ins-del-overlap? patch1 patch2)]))


;; merge? patch patch string -> string OR boolean (input dependent)
;; Consumes two patches and a string. Applies them to the string and returns the result, otherwise returns false if
;; the patches overlap.
(check-expect (merge (make-patch (make-insert "-2-") 3) (make-patch (make-insert "-0-") 5) "01234567890") "012-2-34-0-567890")
(check-expect (merge (make-patch (make-insert "-0-") 5) (make-patch (make-insert "-2-") 3) "01234567890") "012-2-34-0-567890")
(check-expect (merge (make-patch (make-delete 3) 3) (make-patch (make-delete 3) 7) "01234567890") "01260")
(check-expect (merge (make-patch (make-delete 3) 7) (make-patch (make-delete 3) 3) "01234567890") "01260")
(check-expect (merge (make-patch (make-insert "-2-") 7) (make-patch (make-delete 3) 3) "01234567890") "0126789-2-0")
(check-expect (merge (make-patch (make-delete 3) 3) (make-patch (make-insert "-2-") 7) "01234567890") "0126789-2-0")
(check-expect (merge (make-patch (make-delete 3) 3) (make-patch (make-insert "-2-") 3) "01234567890") "012-2-67890") ;; Insertion starting at a deletion
(check-expect (merge (make-patch (make-insert "-2-") 3) (make-patch (make-delete 3) 3) "01234567890") "012-2-67890") ;; <- ditto
(check-expect (merge patch-ins-ex patch-ins-ex "This will return false!") #F)
(define (merge patch1 patch2 str)
	(if (overlap? patch1 patch2)
		#F
		(cond 
			[(and (delete? (patch-op patch1)) (insert? (patch-op patch2)))	;; Apply deletions FIRST
				(apply-patch patch2 (apply-patch patch1 str))]
			[(and (insert? (patch-op patch1)) (delete? (patch-op patch2)))
				(apply-patch patch1 (apply-patch patch2 str))]
			[(>= (patch-pos patch1) (patch-pos patch2))
				(apply-patch patch2 (apply-patch patch1 str))]
			[else
				(apply-patch patch1 (apply-patch patch2 str))])))


;; ================
;; HELPER FUNCTIONS
;; ================

;; insert-overlap? patch patch -> boolean
;; Consumes two patches and returns true if they start at the same location, false otherwise.
(check-expect (insert-overlap? (make-patch (make-insert "Hello ") 1) (make-patch (make-insert "world!") 1)) #T)
(check-expect (insert-overlap? (make-patch (make-insert "Hello ") 1) (make-patch (make-insert "world!") 9)) #F)
(define (insert-overlap? patch1 patch2)
	(= (patch-pos patch1) (patch-pos patch2)))

;; delete-overlap? patch patch -> boolean
;; Consumes two deletion patches and returns true if they overlap, false otherwise.
(check-expect (delete-overlap? (make-patch (make-delete 3) 1) (make-patch (make-delete 4) 2)) #T)
(check-expect (delete-overlap? (make-patch (make-delete 3) 1) (make-patch (make-delete 5) 999)) #F)
(define (delete-overlap? patch1 patch2)
	(not (or ;;original tested for no conflicts, not negates this
		(< (patch-end patch1) (patch-pos patch2))	;; patch1-end < patch2-start
		(> (patch-pos patch1) (patch-end patch2)))))	;; patch1-start > patch2-end

;; ins-del-overlap? patch(insert) patch(delete) -> boolean
;; Consumes two patches and returns true if the insert start is inside the range of the deletion, false otherwise. 
(check-expect (ins-del-overlap? (make-patch (make-delete 9) 1) (make-patch (make-insert "Go away test case!") 3)) #T)
(check-expect (ins-del-overlap? (make-patch (make-insert "Go away test case!") 3) (make-patch (make-delete 9) 99)) #F)
(define (ins-del-overlap? patch1 patch2)
	(cond 
		[(insert? (patch-op patch1))
			(and 
				(> (patch-pos patch1) (patch-pos patch2))	;; delete-start < insert-start <= delete-end
				(<= (patch-pos patch1) (patch-end patch2)))]
		[else
			(and 
				(> (patch-pos patch2) (patch-pos patch1))	;; delete-start < insert-start <= delete-end
				(<= (patch-pos patch2) (patch-end patch1)))]))


;; patch-end patch -> number
;; Consumes a patch, returns the end point of that patch
(check-expect (patch-end (make-patch (make-insert "Hello, world!") 3)) 16)
(check-expect (patch-end (make-patch (make-delete 3) 1)) 4)
(define (patch-end patch)
	(+ (patch-pos patch) (cond 
		[(delete? (patch-op patch)) (delete-len (patch-op patch))]
		[(insert? (patch-op patch)) (string-length (insert-str (patch-op patch)))])))


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

