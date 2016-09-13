;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname hwk3) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
#!/usr/bin/racket
#lang racket				;; These three lines are required to run the program without DrRacket
(require test-engine/racket-tests)



;;  =============================
;;  || DATA & DATA DEFINITIONS ||
;;  =============================


;; A file is (make-file string number string)
(define-struct file (name size contents))
;; Template:
;  (define (file-func a-file)
;	...(file-name a-file)...
;	...(file-size a-file)...
;	...(file-contents a-file)...)
;; Example:
;  (make-file "hwk3.rkt" 8000 "#!/usr/bin/racket\n#lang racket\n(require test-engine/racket-tests)\n\n;; A file is (make-file string number string) [...]"


;; A dir is (make-dir string list[dir] list[file])
(define-struct dir (name dirs files))
;; Template:
;(define (dir-func a-dir)
;	...(dir-name a-dir)...
;	...(cons [(empty? (dir-dirs a-dir)) ...]
;		 [(cons? (dir-dirs a-dir))
;		 	(...(first (dir-dirs a-dir))...
;			 ...(dir-func (rest (dir-dirs a-dir)))...)])
;	...(cons [(empty? (dir-files a-dir)) ...]
;		 [(cons? (dir-files a-dir))
;		 	(...(first (dir-files a-dir))...
;			 ...(dir-func (rest (dir-files a-dir)))...)]))
;; Example: (make-dir "etc" empty empty)
;; Note: if your /etc directory is actually empty, you have some major problems to address.


(define SCHOOL-DIR (make-dir "wpi" empty (list 
			(make-file "Class 1" 5000000 "Class 1 notebook...")
			(make-file "Class 2" 5000000 "Class 2 notebook...")
			(make-file "CS 1102" 4999999 "((((([CS 1102])))))"))))
(define CS1102-DIR (make-dir "CS 1102" (list
			(make-dir "1-Diff" (list (make-file "diff.rkt" 12000 "WE'RE DYING UNDER PARENS")) empty)
			(make-dir "2-Firegame" 	(list
							(make-dir "build" empty empty)
							(make-dir "Hydra-Engine" empty empty))	;;Hail Hydra!
						(list 
							(make-file "HW2.rkt" 180000 "Why didn't we use filter or map?!")
							(make-file "HW2 my version.rkt" 164000 "what have we done?")
							(make-file "lg-fire.gif" 4000 "GIF89.d.d")
							(make-file "med-fire.gif" 4000 "GIF89.d.d")	;;These three are cool. Thank goodness for hex editors!
							(make-file "sm-fire.gif" 4000 "GIF89.d.d")))
			(make-dir "3-Filesystem" empty (list
							(make-file "hwk3.rkt" 666 "NO WAIT DON'T RECURSE THAT DEEP-*boom*"))))
					empty))
(define MISC-DIR (make-dir "misc" (list
					(make-dir "dir1" empty empty)
					(make-dir "dir2" empty (list (make-file "Introducing" 50000000 "rtfs,")))
					(make-dir "dir3" empty empty))
				  (list
				  	(make-file "the" 5000000000000 "racket")
					(make-file "-based" 5 "filesystem!")
					(make-file "...Use" 4 "btrfs")
					(make-file "instead!" 3 "nope."))))

;;  =======================
;;  || PRIMARY FUNCTIONS ||
;;  =======================


;;find-file-path: dir file-> list[string]
;; consumes a directory and a file returns either,
;; false if the file is not in the directory or,
;; a list of directory names for the path to the file
(define (find-file-path rootfs a-file)
   (cond[(not(contains rootfs a-file)) false]
        [else
         (map dir-name (

;;file-names-satisfying

;;files-containing ^^^^ using above

;;  ======================
;;  || Helper Functions ||
;;  ======================

#|
(define (contains alof a-file)
  (not(empty?(filter(lambda (elt) (equal? a-file (first alof))) alof))))
|#


(test)

