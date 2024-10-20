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
    [ Credentials "roman@rmail.com" "roman"
    , Credentials "bun_bun@bmail.com" "bun_bun"
    , Credentials "jeremiah@jmail.com" "jeremiah"
    ]


type PasswordError
    = PasswordEmpty
    | PasswordToShort
    | PasswordToLong
    | PasswordHasNoSpecialCharacters
    | PasswordHasNoNumbers
    | PasswordHasNoCapitalLetters


type EmailError
    = EmailEmpty
    | EmailInvalid


type FormInput error
    = Empty String
    | Valid String
    | Invalid String (List error)


type alias EmailInput =
    FormInput EmailError


type alias PasswordInput =
    FormInput PasswordError


type alias Form =
    { email : EmailInput, password : PasswordInput }


init : Form
init =
    Form (Empty "") (Empty "")


type FormUpdate
    = ChangeEmail String
    | ChangePassword String
    | Submit


view : Form -> Html FormUpdate
view { email, password } =
    form []
        [ viewEmailLabel
        , viewEmailInput email
        , viewPasswordLabel
        , viewPasswordInput password
        , viewSubmitInput
        ]


viewEmailLabel : Html FormUpdate
viewEmailLabel =
    label [ for "email" ] [ text "Email" ]


viewEmailInput : EmailInput -> Html FormUpdate
viewEmailInput email =
    input [ onInput ChangeEmail, type_ "text", id "email", placeholder "enter your email" ] []


viewPasswordLabel : Html FormUpdate
viewPasswordLabel =
    label [ for "password" ] [ text "Password" ]


viewPasswordInput : PasswordInput -> Html FormUpdate
viewPasswordInput password =
    input [ onInput ChangePassword, type_ "text", id "password", placeholder "enter your password" ] []


viewSubmitInput : Html FormUpdate
viewSubmitInput =
    input [ onSubmit Submit, type_ "submit", value "submit" ] []


update : FormUpdate -> Form -> Form
update message model =
    model
