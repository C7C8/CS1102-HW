(load "server.rkt")

(define-script (main form cookies)
  (values
   (html-page "Forum"
              (list 'h1 "CS 1102 Forum")
              (format "Where CS students go to learn")
              (list 'br)
              (list 'br)
              (append (list 'form 
                            (list (list 'action "http://localhost:8088/author")
                                  (list 'target "_blank")))
                      (list(list 'input (list (list 'type "submit") (list 'value "Add New Post"))))))
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
