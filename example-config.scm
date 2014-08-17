(import chicken scheme)
(use vandusen
     vandusen-random-talk ; Include random homestuck chatter
     vandusen-homestuck)

(config `((host . "localhost")
          (channels "#test")
          (nick . "dirkvandusen")
          (homestuck-character . "TT") ; (Dirk)
          (random-talk-delay . 20)
          (random-talk . ,(lambda ()
                            (random-homestuck-line)))))
