(import chicken scheme)
(use files posix irregex http-client html-parser srfi-13)

(include "character-handles.scm")

(define base-uri "http://www.mspaintadventures.com/?s=6&p=00")
(define dialogue-dir "corpus/dialogue/")
(define character-dir "corpus/character/")

(for-each (lambda (d) (create-directory d #t))
          (list dialogue-dir character-dir))

(define handle->character (append-map (lambda (c->h)
                                        (let ((c (car c->h))
                                              (hs (cdr c->h)))
                                          (map (lambda (h) (cons h c)) hs)))
                                      character->handles))

(define (get-dialogue i)
  (let* ((page (with-input-from-request (string-append base-uri
                                                       (number->string i))
                                        #f read-string))
         (dialogue (irregex-search '(: "log</button></div>\n<table width=\"90%\" border=\"0\" cellpadding=\"3\" cellspacing=\"0\">"
                                       (submatch (*? any))
                                       "</table>")
                                   page)))
    (if dialogue
        (irregex-match-substring dialogue 1)
        #f)))

(define (fetch-all-dialogue)
  (let loop ((i 8666))
    (unless (> i 8752)
      (let ((dialogue (get-dialogue i)))
        (print "Fetching page " i)
        (when dialogue
          (with-output-to-file (make-pathname dialogue-dir (number->string i))
            (lambda ()
              (display dialogue)))))
      (loop (add1 i)))))

(define (write-character-line character line page)
  (unless (string= line "")
      (let* ((file (make-pathname character-dir character))
          (f (file-open file (+ open/wronly open/append open/creat))))
     (file-write f page)
     (file-write f "\n")
     (file-write f line)
     (file-write f "\n")
     (file-close f))))

(define (dialogues->characters)
  (let ((files (sort (directory dialogue-dir)
                     string<)))
    (for-each (lambda (f)
                (print "Processing " f)
                (let ((file (with-input-from-file (make-pathname dialogue-dir f)
                              (lambda ()
                                (read-string)))))
                  (let loop ((i 0))
                    (let ((m (irregex-search '(: "<span style=\"color: #"
                                                 (submatch-named color (+ alphanum))
                                                 "\">"
                                               (submatch-named handle (+ alpha)) ":"
                                                 (* space)
                                                 (submatch-named text
                                                                 (+ (~ #\newline))))
                                             file i)))
                      (when m
                        (let ((character (assoc
                                          (string-append (irregex-match-substring m 'handle)
                                                         "-"
                                                         (irregex-match-substring m 'color))
                                                handle->character)))
                          (when character
                            (write-character-line
                             (cdr character)
                             (with-input-from-string (irregex-match-substring m 'text)
                               (lambda ()
                                 (string-trim-both (html-strip))))
                             f)))
                        (loop (irregex-match-end-index m)))))))
              files)))

(fetch-all-dialogue)
(dialogues->characters)
