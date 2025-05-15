17568501378262927451 CONSTANT 1-WORD-SAFE-TAG
17955560168232901695 CONSTANT STR-SAFE-TAG
17891394215867576421 CONSTANT N-WORDS-SAFE-TAG
17587231913923486109 CONSTANT CONS-SAFE-TAG
17838217913774621683 CONSTANT NIL-SAFE-TAG 
18010033749415047015 CONSTANT LAMBDA-SAFE-TAG

: ndrop ( n -- )
  0 DO DROP LOOP ;

: skip-call ( x compile-func -- func-output x )
    { x }
    parse-name evaluate 
    x
; immediate

: safe-pick { idx -- n }

    idx CONS-SAFE-TAG = 
    idx NIL-SAFE-TAG = OR
    idx 1-WORD-SAFE-TAG = OR
    idx STR-SAFE-TAG = OR
    idx N-WORDS-SAFE-TAG = OR
    idx LAMBDA-SAFE-TAG = OR 
    
    if 
       cr ." ERROR: called pick with value instead of an index " cr 
       abort
    then

    
    idx pick 
;


: safe-word-name ( idx -- caddr u ) 
    
    safe-pick { tag }

    tag CONS-SAFE-TAG = if 
       s" CONS" 
       exit
    then

    tag NIL-SAFE-TAG = if 
        s" NIL"
        exit
    then

    tag 1-WORD-SAFE-TAG = if
        s" 1-WORD"
        exit
    then

    tag STR-SAFE-TAG = if
        s" STR"
        exit
    then

    tag N-WORDS-SAFE-TAG = if
        s" N-WORDS"
        exit
    then

    tag LAMBDA-SAFE-TAG = if 
        s" LAMBDA"
        exit
    then

    cr ." ERROR: safe method called on non safe value" cr 
    abort
;

: print-safe-word ( idx -- ) safe-word-name type ;
: stable-print-safe-word { idx -- idx } idx print-safe-word idx ;

: size-in-safe { idx -- n }

    idx safe-pick { tag }

    tag CONS-SAFE-TAG = if 
        idx 1 + pick
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
: size-safe ( idx -- n )  size-in-safe 1 + ;
: drop-safe ( safe-word -- ) 0 size-safe ndrop ;

: get-safe { idx -- safe-word }
    idx size-safe

    dup idx + 1 -
    { p }

    0 DO p pick LOOP
;

: nil-safe ( -- safe-word ) nil-safe-tag ;

: 1-word-safe { x -- safe-word }
    x 1-WORD-SAFE-TAG 
;

: str-safe { caddr u -- safe-word }
    caddr u STR-SAFE-TAG 
; 

: n-words-safe { .. n -- safe-word }
    n N-WORDS-SAFE-TAG
;

: stable-nil-safe { idx -- safe-word } nil-safe-tag idx 1 + ;

: stable-1-word-safe { x idx -- safe-word }
    x 1-WORD-SAFE-TAG 
    2 idx +
;

: stable-str-safe { caddr u idx -- safe-word }
    caddr u STR-SAFE-TAG 
    3 idx +
; 

: stable-n-words-safe { .. n idx -- safe-word }
    n N-WORDS-SAFE-TAG
    2 n idx + +
;



: cons-safe ( safe-word safe-word -- safe-word )
    0 size-safe { idx }
    idx size-safe
    
    idx + 1 +

    CONS-SAFE-TAG
;

: stable-get-safe { idx -- idx safe-word }
    idx get-safe
    0 size-safe idx +
;

: stable-drop-safe ( safe-word idx -- idx )
    { idx }

    0 size-safe
    { size }
    size ndrop
    idx size -
;

: stable-cons-safe ( safe-word safe-word idx -- safe-word idx)
    { idx } 
    cons-safe
    idx 2 + 
;