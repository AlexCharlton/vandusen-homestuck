(module vandusen-homestuck (random-homestuck-line)

(import chicken scheme)
(use vandusen srfi-1 srfi-13 srfi-14 extras files)

(define character-dir (make-pathname (chicken-home) "vandusen-homestuck"))

(define current-corpus '(#f . #f))

(define (random-homestuck-line)
  (unless (equal? (car current-corpus)
                  ($ 'homestuck-character))
    (let* ((file (make-pathname character-dir ($ 'homestuck-character)))
           (contents (with-input-from-file file
                       (lambda ()
                         (read-string))))
           (lines (string-tokenize contents
                                   (char-set-complement (list->char-set '(#\newline)))))
           (n-lines (string->number (string-filter (lambda (c)
                                                     (not (char=? c #\space)))
                                                   (car lines)))))
      (set! current-corpus (cons* ($ 'homestuck-character) n-lines (cdr lines)))))
  (list-ref (cddr current-corpus) (random (cadr current-corpus))))

(plugin 'homestuck
  (lambda ()
    (command 'homestuck
             '(* any)
             (lambda (message)
               (reply-to message (random-homestuck-line)))
             public: #t)))



) ;end vandusen-homestuck
