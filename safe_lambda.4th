\ -----USAE---------------------------------------------------------------------------------------------

\ this module provies a basic lambda calculs setup which is
\   1. fully on the stack 
\   2. mostly safe
\   3. complete
\ 
\ the general idea is to have a stack like so 
\ [ input-safes ] | [ working-safes ] idx [forth values ]

\ stable methods exist in order to keep idx pointing to the same input-safes
\ by inilizing the stable idx to 0
\ the user is allowed to  use stable-get-safe in order to set up function calls
\ this allows the preperation of an arbitrary combination of the existing inputs

\ in addition stable methods are provided in order to allow direct constrcution onto the working set
\ all of these methods follow this signature ( safes idx forth-values )

\ lambdas are a bit weak but the general idea is as follows
\ make a function that takes ( cons runtime capture-time )
\ then call lambda-safe or friends with ( capture-time func-pointer )
\ this gives the same computational power as traditonal lambdas. 
\ however its a bit of a pain


\ ------ BASIC UTILS ----------------------------

17568501378262927451 CONSTANT 1-WORD-SAFE-TAG
17955560168232901695 CONSTANT STR-SAFE-TAG
17891394215867576421 CONSTANT N-WORDS-SAFE-TAG
17587231913923486109 CONSTANT CONS-SAFE-TAG
17838217913774621683 CONSTANT NIL-SAFE-TAG 
18010033749415047015 CONSTANT LAMBDA-SAFE-TAG

: ndrop ( n -- )
  0 DO DROP LOOP ;

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

\ ------ STACK UTILS ----------------------------

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
        idx 1 + pick
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

: stable-get-safe { idx -- safe-word idx }
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

\ ------ NAVIGATION --------------------------------------------

: next-safe { idx -- 'idx } \ skip over one safe word
    idx size-safe
    idx +
;

: next-safe-dup { idx -- idx 'idx } \ gets the next safe word ( without consuming the old index )
    idx size-safe
    idx + 1 +

    idx swap
;

\ ------ CONS --------------------------------------------------

: cons-safe ( safe-word safe-word -- safe-word )
    0 size-safe { idx }
    idx size-safe
    
    idx + 1 +

    CONS-SAFE-TAG
;

: stable-cons-safe ( safe-word safe-word idx -- safe-word idx)
    { idx } 
    cons-safe
    idx 2 + 
;

: unwrap-cons-safe ( safe-word -- car cdr )
    dup CONS-SAFE-TAG = if
        2drop
    else
        ." ERROR: expected CONS found: " 0 print-safe-word abort
    then 
;

\ ------ LAMBDA --------------------------------------------------
: lambda-safe ( safe-word xt -- safe-word )
    { xt } 
    0 size-safe 
    2 + 

    xt swap

    LAMBDA-SAFE-TAG
;

: stable-lambda-safe ( safe-word idx xt -- safe-word idx)
    { idx xt } 
    xt lambda-safe
    idx 3 + 
;

: unwrap-lambda-safe ( safe-word -- capture xt )
    dup LAMBDA-SAFE-TAG = if
        2drop
    else
        ." ERROR: expected LAMBDA found: " 0 print-safe-word abort
    then 
;

: call-lambda-safe ( safe-word lambda -- safe-word? )
    unwrap-lambda-safe
    { xt }
    cons-safe xt execute
;

\ ------ SPECIFIC VALUES --------------------------------------------

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

: stable-1-word-safe { idx x -- safe-word }
    x 1-WORD-SAFE-TAG 
    2 idx +
;

: stable-str-safe { idx caddr u -- safe-word }
    caddr u STR-SAFE-TAG 
    3 idx +
; 

: stable-n-words-safe (  idx .. n-- safe-word )
    { n }
    n pick { idx }

    n N-WORDS-SAFE-TAG
    2 n idx + +
;


\ ------ UNWRAP METHODS ----------------------------

: unwrap-1-word ( safe-word -- x )
    dup 1-WORD-SAFE-TAG =
    if drop 
    else ." ERROR: expected 1-word found: "
        0 print-safe-word
        abort
    then 
;

: unwrap-str-safe ( safe-word -- caddr u )
    dup STR-SAFE-TAG = if
        1 pick   \ u
        pick     \ caddr
        swap
        2drop
    else
        ." ERROR: expected STR found: " 0 print-safe-word abort
    then 
;

: unwrap-n-words-safe ( safe-word -- .. n )
    dup N-WORDS-SAFE-TAG = if
        1 pick   \ get n
        dup >r   \ stash n
        r@ 1 + ndrop
        r>
    else
        ." ERROR: expected N-WORDS found: " 0 print-safe-word abort
    then 
;


: unwrap-nil ( safe-word -- )
    dup NIL-SAFE-TAG = if drop
    else
        ." ERROR: expected NIL found: " 0 print-safe-word abort
    then 
;



