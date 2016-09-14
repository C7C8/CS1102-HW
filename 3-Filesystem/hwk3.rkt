#!/usr/bin/racket
;#lang racket
(require test-engine/racket-tests)
(require racket/list)



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
			(make-dir "1-Diff" empty (list (make-file "diff.rkt" 12000 "WE'RE DYING UNDER PARENS")))
			(make-dir "2-Firegame" 	(list
							(make-dir "build" empty empty)
							(make-dir "Hydra-Engine" empty empty))
						(list 
							(make-file "HW2.rkt" 180000 "Why didn't we use filter or map?!")
							(make-file "HW2 my version.rkt" 164000 "what have we done?")
							(make-file "lg-fire.gif" 4000 "GIF89.d.d")
							(make-file "med-fire.gif" 4000 "GIF89.d.d")
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
					(make-file "-based" 0 "filesystem!")
					(make-file "...Use" 0 "btrfs")
					(make-file "instead!" 0 "nope."))))



;;  =======================
;;  || PRIMARY FUNCTIONS ||
;;  =======================


;; any-huge-files? dir number -> boolean
;; Consumes a filesystem (starting at the given root directory), returns true
;; if there are files within it that exceed the given size.
(check-expect (any-huge-files? MISC-DIR 5000) true)
(check-expect (any-huge-files? CS1102-DIR 190000) false)
(check-expect (any-huge-files? CS1102-DIR 600) true)
(define (any-huge-files? rootfs size)
	(cond 	[(cons? (filter (lambda (x)(> (file-size x) size)) (dir-files rootfs))) true]
		[else (ormap (lambda (fs)(any-huge-files? fs size)) (dir-dirs rootfs))]))


;; clean-directory: dir -> dir
;; Consumes a filesystem (starting at the given root directory), returns
;; the same filesystem but with files of size 0 removed.
;; NOTE: WHEN RUNNING DIRECTLY OR RUNNING WITHOUT "Intermediate student with lambda"
;; THIS TEST CASE WILL THROW AN ERROR! THIS IS BIZARRELY NORMAL!
(check-expect (clean-directory MISC-DIR) (make-dir "misc" (list
								(make-dir "dir1" empty empty)
								(make-dir "dir2" empty (list (make-file "Introducing" 50000000 "rtfs,")))
								(make-dir "dir3" empty empty))
							  (list (make-file "the" 5000000000000 "racket"))))
(define (clean-directory rootfs)
	(make-dir (dir-name rootfs)
		  (map clean-directory (dir-dirs rootfs))
		  (filter (lambda (f)(> (file-size f) 0)) (dir-files rootfs))))
			

;; find-file-path: dir file-> list[string]
;; consumes a directory and a file returns either,
;; false if the file is not in the directory or,
;; a list of directory names for the path to the file
(check-expect (find-file-path MISC-DIR (make-file "lallALA" 0 "not a file")) false)
(check-expect (find-file-path MISC-DIR (make-file "...Use" 0 "btrfs")) (list "misc")) 
(check-expect (find-file-path CS1102-DIR (make-file "diff.rkt" 12000 "WE'RE DYING UNDER PARENS")) (list "CS 1102" "1-Diff"))
(define (find-file-path rootfs a-file)
 (cond[(cons? (map dir-name (filter(lambda(f) (contains-file? f (file-name a-file))) (dir-dirs rootfs))))
         (cons(dir-name rootfs)(map dir-name (filter(lambda(f) (contains-file? f (file-name a-file))) (dir-dirs rootfs))))]       
      [(contains-file? rootfs (file-name a-file)) (list(dir-name rootfs))]
      [else false]))              


;; file-names-satisfying: (file -> boolean) dir -> list[string]
;; Consumes a filesystem (given by a root directory), returns a list
;; of filenames whose respective files yielded a "true" result from the
;; function passed in as the first argument.
(check-expect (file-names-satisfying (lambda (f)(string=? "the" (file-name f))) MISC-DIR) (list "the"))
(check-expect (file-names-satisfying (lambda (f)(string=? "GIF89.d.d" (file-contents f))) CS1102-DIR) (list "lg-fire.gif" "med-fire.gif" "sm-fire.gif"))
(define (file-names-satisfying func rootfs)
		(append*
			(map file-name (filter func (dir-files rootfs)))
			(map (lambda (d)(file-names-satisfying func d)) (dir-dirs rootfs))))


;; files-containing: dir string -> list[strings]
;; Consumes a directory and a value, returns a list of filenames
;; that have the given value as their contents.
(check-expect (files-containing CS1102-DIR "GIF89.d.d") (list "lg-fire.gif" "med-fire.gif" "sm-fire.gif"))
(check-expect (files-containing CS1102-DIR "This doesn't exist") empty)
(define (files-containing rootfs val)
	(file-names-satisfying (lambda (f)(string=? val (file-contents f))) rootfs))



;;  ======================
;;  || Helper Functions ||
;;  ======================


;; contains-file? dir string -> boolean
;; Consumes a filesystem (given as a root directory) and a filename,
;; returns true if a file by that name is present in the filesystem.
(check-expect (contains-file? CS1102-DIR "sm-fire.gif") true)
(check-expect (contains-file? MISC-DIR "dne") false)
(define (contains-file? rootfs filename)
	(or 
		(cons? (filter (lambda (f)(string=? filename (file-name f))) (dir-files rootfs)))
		(ormap (lambda (fs)(contains-file? fs filename)) (dir-dirs rootfs))))

