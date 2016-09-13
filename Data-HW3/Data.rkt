;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname Data) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;;=====================================
;; Michael Krebs and Christopher Myers 
;;=====================================



(define-struct file(name size content))
(define-struct dir(name dirs files))
;;========================
;; Constants and Resources
;;========================
(define CS1(make-file "Dr.Racket HW1" 1765 empty))
(define CS2(make-file "Dr.Racket HW2" 1250 empty))
(define CS3(make-file "Dr.Racket HW3" 0 empty))

(define MA1(make-file "LTC HW1" 1965 empty))
(define MA2(make-file "FTOC HW2" 1250 empty))
(define MA3(make-file "Taylor Series HW3" 1765 empty))

(define PH1(make-file "1D/2D Motion HW1" 0 empty))
(define PH2(make-file "Netwon Forces HW2" 1250 empty))
(define PH3(make-file "Electromagnetism HW3" 765 empty))

(define delta(make-dir "PH 1110 HW" empty (list PH1 PH2 PH3)))
(define charlie(make-dir "MA 1023 HW" empty (list MA1 MA2 MA3)))
(define beta(make-dir "CS 1102 HW" empty (list CS1 CS2 CS3)))
(define alpha(make-dir "College_Stuff" (list beta charlie delta) empty))

;; Testing to ensure that the directories work
;;==========================================================================================
(check-expect (file-name (first (dir-files(first(dir-dirs alpha))))) "Dr.Racket HW1")
(check-expect (file-name (first (dir-files(first(rest(dir-dirs alpha)))))) "LTC HW1")
(check-expect (file-name (first (rest(dir-files(first(dir-dirs alpha)))))) "Dr.Racket HW2")
(check-expect (file-name (first (rest(dir-files(first(rest(dir-dirs alpha))))))) "FTOC HW2")
(check-expect (file-name (first (rest(rest(dir-files(first(rest(rest(dir-dirs alpha))))))))) "Electromagnetism HW3")
;;==========================================================================================

(check-expect (any-huge-files? 1300 (dir-files delta)) false)
(check-expect (any-huge-files? 1300 (dir-files charlie)) true)
(check-expect (any-huge-files? 1300 (dir-files(first(dir-dirs alpha)))) true)
(check-expect (any-huge-files? 0 empty) false)
(define (any-huge-files? anum alof)
  (not(empty? (filter(lambda(elt) (> elt anum))(map file-size alof)))))

(check-expect (clean-directory (dir-files delta)) (list PH2 PH3))
(check-expect (clean-directory (dir-files charlie)) (list MA1 MA2 MA3))
(define (clean-directory alof)
  (filter(lambda(a-file) (> (file-size a-file)0)) alof))


(check-expect (find-file-path beta CS1) (list "beta"))
(define (find-file-path alof a-file)
  (map file-name (
|#
;;file-names-satisfying

;;using above^^^ make files containing

;;================
;;Helper Functions
;;================

#|
(define (contains alof a-file)
  (not(empty?(filter(lambda (elt) (equal? a-file (first alof))) alof))))
|#