module Form exposing (..)

import Html exposing (text)


main =
    text "hello world"


type alias Credentials =
    { email : String, password : String }


database : List Credentials
database =
    [ Credentials "jeremiah@jmail.com" "jeremiah"
    , Credentials "roman@rmail.com" "roman"
    , Credentials "bun_bun@bmail.com" "bun_bun"
    ]
