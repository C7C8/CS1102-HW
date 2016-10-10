(load "server.rkt")
(require test-engine/racket-tests)
(require racket/string)

;; Christopher Myers and Michael Krebs


;; ======================
;; || POST FUNCTIONS ||
;; ======================

;; A post is (make-post string string string)
(define-struct post (author title body))

;; list[post]
(define mem (list (make-post "crmyers" "Test post" "Test content")
                  (make-post "mjkrebs" "Test pos2" "Test conten2")
                  (make-post "dillo" "[no title]" "DEAD")))

(define (add-post npost)
  (set! mem (cons npost mem)))


;; post->string: post -> string
;; Does what it says on the box.
(check-expect (post->string (make-post "crmyers" "Test post" "Test content"))
              "crmyers      Test post      Test content<br/>")
(define (post->string pst)
  (string-append (post-author pst) "      " (post-title pst) "      " (post-body pst) "<br/>"))

;; posts->string: list[post] -> string
;; Also does what it says on the box. Turns a list of posts into strings!
(check-expect (posts->string (list (make-post "crmyers" "Test post" "Test content")
                             (make-post "mjkrebs" "Test pos2" "Test conten2")))
  "<p>crmyers      Test post      Test content<br/>mjkrebs      Test pos2      Test conten2<br/></p>")
(define (posts->string pstlst)
  (string-append "<p>" (string-append* (map post->string pstlst)) "</p>"))

;; =================
;; || WEB SCRIPTS || 
;; =================

(define-script (main form cookies) ; args ignored... somehow
  (values 
   (html-page "Main Page"
              (list 'h1 "Racket Forum")
              "Author         Title          Body"
              (list 'br)
              (string->xexpr (posts->string mem)))
   false))

(define-script (author form cookies)
  (values
   (html-page "Authoring"
              (list 'h1 "Authoring Page")
              (format "Write your name and post below")
              (append (list 'form 
                            (list (list 'action "http://localhost:8088/preview")
                                  (list 'target "_blank")))
                      (list (list 'br)
                            "Name:" (list 'input (list (list 'type "text") (list 'name "Name")))
                            (list 'br)
                            (list 'br)
                            "Title:"(list 'input (list (list 'type "text") (list 'name "Title")))
                            (list 'br)
                            (list 'br)
                            "Post:"(list 'input (list (list 'type "text") (list 'name "Post")))
                            (list 'br)
                            (list 'br)
                            (list 'input (list (list 'type "submit") (list 'name "Preview"))))))
   false))
#|
(define-script (preview form cookies)
  (let ([AUTHOR (cdr (assoc 'name form))]
        
        
  (values
   (html-page "preview"
              (list 'h1 "Preview")
                (append (list 'form 
                            (list (list 'action "http://localhost:8088/main")
                                  (list 'target "_blank")))
                        (list (list 'input (list(list 'type "submit") (list 'value "Submit"))))))
   false))|#


(test)
