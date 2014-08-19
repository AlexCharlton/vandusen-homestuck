(module vandusen-homestuck (random-homestuck-line
                            switch-persona)

(import chicken scheme)
(use irc vandusen srfi-1 srfi-13 srfi-14 extras files)
(include "character-handles.scm")

(define character-dir (make-pathname (chicken-home) "vandusen-homestuck"))

(define current-corpus '(#f . #f))

(define source #f)

(define (random-homestuck-line)
  (unless (equal? (car current-corpus)
                  ($ 'homestuck-character))
    (let* ((file (make-pathname character-dir ($ 'homestuck-character)))
           (contents (with-input-from-file file
                       (lambda ()
                         (read-string))))
           (lines (string-tokenize contents
                                   (char-set-complement
                                    (list->char-set '(#\newline))))))
      (set! current-corpus (cons ($ 'homestuck-character) lines))))
  (let* ((n-lines (length (cdr current-corpus)))
         (r (random n-lines))
         (i (+ r 1 (- (modulo r 2)))))
    (set! source (list-ref (cdr current-corpus) (sub1 i)))
    (list-ref (cdr current-corpus) i)))

(define (switch-persona persona)
  (if (assoc (string-downcase persona) character->handles)
      ($ 'homestuck-character (string-downcase persona))
      (begin (say (string-append "I don't know who " persona " is."))
             #f)))

(plugin 'homestuck
  (lambda ()
    (command 'homestuck
             '(* any)
             (lambda (message)
               (reply-to message (random-homestuck-line)))
             public: #t)
    (command 'persona
             '(: "persona" (? ":") (+ space) (submatch (+ alpha)))
             (lambda (msg character)
               (when (switch-persona character)
                 (say (random-homestuck-line)))))
    (command 'personas
             '(: "personas")
             (lambda (msg)
               (reply-to msg (string-join (map car character->handles)
                                          ", "))))
    (command 'cite
             '(: "cite")
             (lambda (msg)
               (when source
                 (reply-to msg (string-append
                                "http://www.mspaintadventures.com/?s=6&p=00"
                                source)))))
    ))

) ;end vandusen-homestuck
