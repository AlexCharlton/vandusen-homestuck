(module vandusen-homestuck (random-homestuck-line)

(import chicken scheme)
(use vandusen srfi-13 srfi-14 extras files)

(define character-dir (make-pathname (chicken-home) "vandusen-homestuck"))

(define (random-homestuck-line)
  (let* ((file (make-pathname character-dir ($ 'homestuck-character)))
         (contents (with-input-from-file file
                     (lambda ()
                       (read-string))))
         (lines (string-tokenize contents
                                 (char-set-complement (list->char-set '(#\newline)))))
         (n-lines (string->number (string-filter (lambda (c)
                                                   (not (char=? c #\space)))
                                                 (car lines)))))
    (list-ref lines (random n-lines))))

(plugin 'homestuck
  (lambda ()
    (command 'homestuck
             '(* any)
             (lambda (message)
               (reply-to message (random-homestuck-line)))
             public: #t)))



) ;end vandusen-homestuck
