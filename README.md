# vandusen-homestuck
vandusen-homestuck is an extension for the [vandusen](http://wiki.call-cc.org/eggref/4/vandusen) IRC bot that makes vandusen talk back as your favourite Homestuck character.

## Installation
This repository is a [Chicken Scheme](http://call-cc.org/) egg.

It can be installed by downloading the repository and executing `chicken-install vandusen-homestuck`.

If you want to update the corpus (for any reason), you should delete the `corpus` directory, run `csi scraper.scm` and then re-install. This will take a while.

## Requirements
- vandusen
- http-parser (only for the scraper)
- http-client (only for the scraper)

## Documentation
Aside from needing to be included in your vandusen config file, vandusen-homestuck introduces one new vandusen variable:

- `homestuck-character`: The name of your desired character.

### vandusen commands
    persona <character>

Switch the persona of vandusen.

    personas

List the available personas.

    cite

Return the url of the previous quote.

## Examples
This example can be run with `vandusen example-config.scm`

```scheme
(import chicken scheme)
(use vandusen
     vandusen-random-talk ; Include random homestuck chatter
     vandusen-homestuck)

(config `((host . "localhost")
          (channels "#test")
          (homestuck-character . "dirk")
          (nick . "dirkvandusen")
          (random-talk-delay . 20)
          (random-talk . ,(lambda ()
                            (random-homestuck-line)))))
```

## Version history
### Version 0.2.0
* Fixed corpus
* Added `persona`, `personas`, `cite` commands

### Version 0.1.0
* Initial release

## Source repository
Source available on [GitHub](https://github.com/AlexCharlton/vandusen-homestuck).

Bug reports and patches welcome! Bugs can be reported via GitHub or to alex.n.charlton at gmail.

## Author
Alex Charlton

## License
BSD
