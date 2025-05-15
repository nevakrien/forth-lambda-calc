17568501378262927451 CONSTANT 1-WORD-SAFE-TAG
17955560168232901695 CONSTANT STR-SAFE-TAG
17891394215867576421 CONSTANT N-WORDS-SAFE-TAG
17587231913923486109 CONSTANT CONS-SAFE-TAG
17838217913774621683 CONSTANT NIL-SAFE-TAG 
18010033749415047015 CONSTANT LAMBDA-SAFE-TAG

: ndrop ( n -- )
  0 DO DROP LOOP ;


: size-in-safe ( n -- n )    
    { idx }

    idx pick { tag }

    tag CONS-SAFE-TAG = if 
        idx 1 - pick
        exit
    then

    tag NIL-SAFE-TAG = if 
        0
        exit
    then

    tag 1-WORD-SAFE-TAG = if
        1
        exit
    then

    tag STR-SAFE-TAG = if
        2
        exit
    then

    tag N-WORDS-SAFE-TAG = if
        idx 1 + pick 1 +
        exit
    then

    tag LAMBDA-SAFE-TAG = if 
        idx 1 - pick
        exit
    then

    cr ." ERROR: safe method called on non safe value" cr 
    abort
;
: size-safe ( n -- n )  size-in-safe 1 + ;


: drop-safe ( safe-word -- ) 0 size-safe ndrop ;

: get-safe ( n -- safe-word )
    { spot }
    spot size-safe

    dup spot + 1 -
    { p }

    0 DO p pick LOOP
;