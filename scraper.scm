(import chicken scheme)
(use files posix irregex http-client html-parser)

(define base-uri "http://www.mspaintadventures.com/?s=6&p=00")
(define dialogue-dir "corpus/dialogue/")
(define character-dir "corpus/character/")

(define (get-dialogue i)
  (let* ((page (with-input-from-request (string-append base-uri
                                                       (number->string i))
                                        #f read-string))
         (dialogue (irregex-search '(: "Hide Pesterlog</button></div>\n<table width=\"90%\" border=\"0\" cellpadding=\"3\" cellspacing=\"0\">"
                                       (submatch (*? any))
                                       "</table>")
                                   page)))
    (if dialogue
        (with-input-from-string (irregex-match-substring dialogue 1)
          (lambda ()
            (html-strip)))
        #f)))

(define (fetch-all-dialogue)
  (let loop ((i 1926))
    (unless (> i 8752)
      (let ((dialogue (get-dialogue i)))
        (print "Fetching page " i)
        (when dialogue
          (with-output-to-file (string-append dialogue-dir (number->string i))
            (lambda ()
              (display dialogue)))))
      (loop (add1 i)))))

(define (write-character-line character line)
  (let* ((file (string-append character-dir character))
         (exists? (file-exists? file))
         (f (file-open file (+ open/wronly open/append open/creat))))
    (unless exists?
      (file-write f "0000000\n"))
    (file-write f line)
    (file-write f "\n")
    (file-close f)))

(define (line-count file)
  (let* ((contents (with-input-from-file file
                     (lambda ()
                       (read-string))))
         (n-lines (sub1 (string-fold (lambda (c i)
                                       (if (char=? c #\newline) (add1 i) i))
                                     0 contents)))
        (f (file-open file open/wronly)))
    (file-write f (string-pad (number->string n-lines) 7))))

(define (dialogues->characters)
  (let ((files (sort (directory dialogue-dir)
                     string<)))
    (for-each (lambda (f)
                (print "Processing " f)
                (let ((file (with-input-from-file (string-append dialogue-dir f)
                              (lambda ()
                                (read-string)))))
                  (let loop ((i 0))
                    (let ((m (irregex-search '(: (submatch-named handle (+ upper)) ":"
                                                 (* space)
                                                 (submatch-named text
                                                                 (+ (~ #\newline))))
                                             file i)))
                      (when m
                        (write-character-line (irregex-match-substring m 'handle)
                                              (irregex-match-substring m 'text))
                        (loop (irregex-match-end-index m)))))))
              files))
  (let ((files (directory character-dir)))
    (for-each (lambda (f)
                (line-count (string-append character-dir f)))
              files)))

(fetch-all-dialogue)
(dialogues->characters)
