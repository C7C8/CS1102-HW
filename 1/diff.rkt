#!/usr/bin/racket
;;#lang racket				;; These three lines are required to run the program without DrRacket
(require test-engine/racket-tests)

;;
;; File by Michael Krebs and Christopher Myers
;; 2016-9-1
;;

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
;; Consumes a patch and a string, returns a patched string
(check-expect (apply-patch patch-ins-ex "We are not programmers.") "We are not lazy programmers.")
(check-expect (apply-patch patch-del-ex "I don't have other example sentences.") "I don't have example sentences.")
(define (apply-patch patch str)
	(apply-op (patch-op patch) (patch-pos patch) str))


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
			

;; overlap?: patch patch -> boolean
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


;; merge?: patch patch string -> string OR boolean (input dependent)
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


;; modernize: string -> string
;; Consumes a string and applies a series of patches to modernize it. Intended to
;; operate on the sequence from "Hamlet"
(check-expect (modernize hamlet-str) hamlet-str-modern)
(define (modernize str)
	(patch-walker modernize-patchlist str))


;;Data for the modernize function
(define hamlet-str "Hamlet: Do you see yonder cloud that's almost in shape of a camel? Polonius: By the mass, and 'tis like a camel, indeed. Hamlet: Methinks it is like a weasel. Polonius: It is backed like a weasel. Hamlet: Or like a whale? Polonius: Very like a whale.\n\n\n")
(define hamlet-str-modern "Hamlet: Do you see the cloud over there that's almost the shape of a camel? Polonius: By golly, it is like a camel, indeed. Hamlet: I think it looks like a weasel. Polonius: It is shaped like a weasel. Hamlet: Or like a whale? Polonius: It's totally like a whale.\n\n\n")
(define modernize-patchlist 	(cons (make-patch (make-delete 4) 232)
				(cons (make-patch (make-insert "It's totally") 232)
				(cons (make-patch (make-delete 6) 175)
				(cons (make-patch (make-insert "shaped") 175)
				(cons (make-patch (make-delete 14) 129)
				(cons (make-patch (make-insert "I think it looks") 129)
				(cons (make-patch (make-delete 8) 90)
				(cons (make-patch (make-insert "it is") 90)
				(cons (make-patch (make-delete 8) 80)
				(cons (make-patch (make-insert "golly") 80)
				(cons (make-patch (make-delete 2) 46)
				(cons (make-patch (make-insert "the") 46)
				(cons (make-patch (make-delete 19) 19)
				(cons (make-patch (make-insert "the cloud over there that's") 19) ;;parens incoming
				empty)))))))))))))))


;; ================
;; HELPER FUNCTIONS
;; ================


;; patch-walker: list of patches, string -> string
;; Takes a list of patches, recursively applies them
(check-expect (patch-walker (cons (make-patch (make-delete 1) 8) (cons (make-patch (make-insert "9") 8) empty)) "0123456789") "0123456799")
(check-expect (patch-walker (cons (make-patch (make-delete 1) 1) (cons (make-patch (make-insert "2") 1) empty)) "0123456789") "0223456789")
(define (patch-walker patchlist str)
	(cond
		[(empty? patchlist) str]
		[else (patch-walker (rest patchlist) (apply-patch (first patchlist) str))]))


;; insert-overlap?: patch patch -> boolean
;; Consumes two patches and returns true if they start at the same location, false otherwise.
(check-expect (insert-overlap? (make-patch (make-insert "Hello ") 1) (make-patch (make-insert "world!") 1)) #T)
(check-expect (insert-overlap? (make-patch (make-insert "Hello ") 1) (make-patch (make-insert "world!") 9)) #F)
(define (insert-overlap? patch1 patch2)
	(= (patch-pos patch1) (patch-pos patch2)))

;; delete-overlap?: patch patch -> boolean
;; Consumes two deletion patches and returns true if they overlap, false otherwise.
(check-expect (delete-overlap? (make-patch (make-delete 3) 1) (make-patch (make-delete 4) 2)) #T)
(check-expect (delete-overlap? (make-patch (make-delete 3) 1) (make-patch (make-delete 5) 999)) #F)
(define (delete-overlap? patch1 patch2)
	(not (or ;;original tested for no conflicts, not negates this
		(< (patch-end patch1) (patch-pos patch2))	;; patch1-end < patch2-start
		(> (patch-pos patch1) (patch-end patch2)))))	;; patch1-start > patch2-end

;; ins-del-overlap?: patch(insert) patch(delete) -> boolean
;; Consumes two patches and returns true if the insert start is inside the range of the deletion, false otherwise.
;; Hence, "insert-delete-overlap"
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


;; patch-end patch: -> number
;; Consumes a patch, returns the end point of that patch
(check-expect (patch-end (make-patch (make-insert "Hello, world!") 3)) 16)
(check-expect (patch-end (make-patch (make-delete 3) 1)) 4)
(define (patch-end patch)
	(+ (patch-pos patch) (cond 
		[(delete? (patch-op patch)) (delete-len (patch-op patch))]
		[(insert? (patch-op patch)) (string-length (insert-str (patch-op patch)))])))


;; str-delete: number number string -> string
;; Consumes a starting position, an amount to delete and the string to delete from
;; Produces a string with specified deleted portion via starting position and deleted amount
(check-expect (str-delete 2 2 "apples") "apes")
(check-expect (str-delete 1 5 "0123456") "06")
(define (str-delete position num str)
	(string-append (substring str 0 position) (substring str (+ position num))))


;; str-insert: number string string -> string
;; Consumes a position, a string, and a substring. Inserts substr at position in str, returning the result.
(check-expect (str-insert 4 "The fox" "quick brown " ) "The quick brown fox")
(check-expect (str-insert 14 "jumps over the dog." " lazy") "jumps over the lazy dog.")
(define (str-insert position str substr)
	(string-append 
	(substring str 0 position)
	substr
	(substring str position (string-length str))))

;;(test) ;; Run check-expect tests. Not needed if DrRacket is configured in "Beginning Student" mode.


;  7.The advantages to returning false instead of the original string in the case where
; there is an overlap of two patches is that immediately one can know that the patches overlapped
; and didn't instead have a minor error like an index issue. This saves the coder the
; time of searching through the returned string looking for a patch that failed to be
; performed correctly when none of the patches were performed at all. 
;
; 8.(/ (- (* 9 3) (double 'a)) 2) where double is defined as (define (double n) (* n 2))
;
; =(/ (- (27) (double 'a)) 2)
;
; =(/ (- (27) (* a' 2)) 2)
;
; = Error: double n suspected a number but what given a'. They cannot be multiplied together
;
;
; 9.(or (< 5 2) (and (= 15 (- 18 3)) (> 8 4)))
;
; =(or (false) (and (= 15 (- 18 3)) (> 8 4)))
;
; =(or (false) (and (= 15 (15)) (> 8 4)))
;
; =(or (false) (and (true) (> 8 4)))
;
; =(or (false) (and (true) (true)))
;
; =(or (false) (true))
;
; = true
;
;
; 10.(and (+ 5 -1) false)
;
;  =(and (4) false)
;
;  = Error: and returns a boolean and since 4 is neither an and or else the and cannot be evaluated
;
; 11.(apply-patch 'remove "this is a test string") [use your own apply-patch program from this assignment]
;
;  = Error: apply-patch requires (patch string) as arguments but was given (symbol string).
;    Our program doesn't use symbols to create an operation, only make-insert and make-delete do.
;
;
; 12. Code that produces this error would be anything with an incomplete cond; there's a test but no action after that.
;	Example: (cond #T)
; 
; 13. A variable-undefined error is generated when a variable used in a function doesn't actually exist.
;	Example: (+ x 1)
;
; 14. This error would be generated if you used a number after an open paren, but that number wasn't a function.
;	Example: (4)

