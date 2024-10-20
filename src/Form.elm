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


type PasswordError
    = PasswordEmpty
    | PasswordToShort
    | PasswordToLong
    | PasswordHasNoSpecialCharacters
    | PasswordHasNoNumbers
    | PasswordHasNoCapitalLetters


type PasswordInput
    = PasswordDefaultValue String
    | PasswordValid { value : Result (List PasswordError) String }


type EmailError
    = EmailEmpty
    | EmailInvalid


type EmailInput
    = EmailDefaultValue String
    | EmailValid { value : Result (List EmailError) String }


type alias Form =
    { email : EmailInput, password : PasswordInput }


init : Form
init =
    Form (EmailDefaultValue "") (PasswordDefaultValue "")


type FormUpdate
    = ChangeEmail String
    | ChangePassword String
