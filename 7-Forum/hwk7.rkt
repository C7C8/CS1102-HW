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

;; Add a post to memory. No check-expects as it uses a set!.
(define (add-post npost)
  (set! mem (cons npost mem)))


;; post->string: post -> string
;; Does what it says on the box.
(check-expect (post->string (make-post "crmyers" "Test post" "Test content"))
              "<i>By crmyers</i><br/><h3>Test post</h3><p>Test content</p><br/><br/>")
(define (post->string pst)
  (string-append "<i>By " (post-author pst) "</i><br/><h3>" (post-title pst) "</h3><p>" (post-body pst) "</p><br/><br/>"))

;; posts->string: list[post] -> string
;; Also does what it says on the box. Turns a list of posts into strings!
(check-expect (posts->string (list (make-post "crmyers" "Test post" "Test content")
                             (make-post "mjkrebs" "Test pos2" "Test conten2")))
  "<p><i>By crmyers</i><br/><h3>Test post</h3><p>Test content</p><br/><br/><i>By mjkrebs</i><br/><h3>Test pos2</h3><p>Test conten2</p><br/><br/></p>")
(define (posts->string pstlst)
  (string-append "<p>" (string-append* (map post->string pstlst)) "</p>"))

;; =================
;; || WEB SCRIPTS || 
;; =================

(define-script (main form cookies) ; args ignored... somehow
  (values 
   (html-page "Main Page"
              (list 'h1 "Racket Forum")
              (list 'br)
              (string->xexpr (posts->string mem))
              (append (list 'form 
                            (list (list 'action "http://localhost:8080/author")))
                      (list (list 'input (list (list 'type "submit")(list 'value "Add New Post"))))))
   false))

(define-script (author form cookies)
  (values
   (html-page "Authoring"
              (list 'h1 "Authoring Page")
              (format "Write your name and post below")
              (append (list 'form 
                            (list (list 'action "http://localhost:8080/preview")
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
                            (list 'input (list (list 'type "submit") (list 'value "Preview"))))))
   false))


(define-script (preview form cookies)
  (let ([AUTHOR (cdr (assoc 'Name form))]
        [TITLE (cdr (assoc 'Title form))]
        [BODY (cdr (assoc 'Post form))])
    (values
     (html-page "Post Preview"
                (list 'h1 "Preview submission")
                (list 'br)
               "Preview your submission here. Press \"back\" to change your
               submission or \"submit\" to submit. Be careful, there is no
               editing or deleting posts!"
                (list 'br)
                (list 'br)
                (list 'p )
                (string-append "Author: " AUTHOR)
                (list 'br)
                (list 'h3 TITLE)
                (string->xexpr (string-append "<p>" BODY "</p>"))
                (list 'form
                      (list 'button (list
                                         (list 'formaction "http://localhost:8080/accept")
                                         (list 'target "_blank")
                                         (list 'type "submit"))
                            "Submit Post")
                       (list 'button (list
                                         (list 'formaction "http://localhost:8080/author")
                                         (list 'type "submit"))
                            "Cancel")
                      (list 'input (list (list 'type "hidden")
                                         (list 'name "title")
                                         (list 'value TITLE)))
                      (list 'input (list (list 'type "hidden")
                                         (list 'name "body")
                                         (list 'value BODY)))
                      (list 'input (list (list 'type "hidden")
                                         (list 'name "author")
                                         (list 'value AUTHOR)))))
     false)))

(define-script (accept form cookies)
  (let ([AUTHOR (cdr (assoc 'author form))]
        [TITLE (cdr (assoc 'title form))]
        [BODY (cdr (assoc 'body form))])
    (begin
      (add-post (make-post AUTHOR TITLE BODY))
      (values
       (html-page "Post submitted"
                  (list 'h1 "Success!")
                  (list 'p "Your post has been submitted!")
                  (list 'a (list (list 'href "http://localhost:8080/main"))
                        "Click here to return to the main page."))
       false))))

(test)
(server 8080)
