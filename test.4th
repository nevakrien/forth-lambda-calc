include safe_lambda.4th

." starting test" cr


." loading cons and 1" cr

nil-safe nil-safe cons-safe

1 1-word-safe


." searching the second" cr

0 next-safe get-safe

." unwraping" cr

unwrap-cons-safe unwrap-nil unwrap-nil

: test-lambda ( nil [1-word 1] cons -- ni; )
    unwrap-cons-safe
    unwrap-1-word
    = 1 invert if abort 
    then

    unwrap-nil
    nil-safe
;

." minting lambda" cr

' test-lambda lambda-safe
0

." calling lambda" cr

stable-nil-safe
get-safe call-lambda-safe

." droping whats left" cr

drop-safe drop-safe

." all tests passed" cr

bye
