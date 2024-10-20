module Form exposing (..)

import Browser
import Html exposing (Html, form, input, label, text)
import Html.Attributes exposing (for, id, placeholder, type_, value)
import Html.Events exposing (onInput, onSubmit)


main =
    Browser.sandbox { init = init, view = view, update = update }


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
    | Submit


view : Form -> Html FormUpdate
view model =
    form []
        [ label [ for "email" ] [ text "Email" ]
        , input [ onInput ChangeEmail, type_ "text", id "email", placeholder "enter your email" ] []
        , label [ for "password" ] [ text "Password" ]
        , input [ onInput ChangePassword type_ "text", id "password", placeholder "enter your password" ] []
        , input [ type_ "submit", value "submit" ] []
        ]


update : FormUpdate -> Form -> Form
update message model =
    model
