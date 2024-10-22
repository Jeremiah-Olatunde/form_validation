module Form exposing (..)

import Browser
import Html exposing (Html, br, form, input, label, text)
import Html.Attributes exposing (for, id, placeholder, readonly, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Regex


main =
    Browser.sandbox { init = init, view = view, update = update }



-------------------------------------------------------------------------------
-- DATA
-------------------------------------------------------------------------------


type alias Credentials =
    { email : String, password : String }


database : List Credentials
database =
    [ Credentials "roman@rmail.com" "roman"
    , Credentials "bun_bun@bmail.com" "bun_bun"
    , Credentials "jeremiah@jmail.com" "jeremiah"
    ]



-------------------------------------------------------------------------------
-- MODELING
-------------------------------------------------------------------------------


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
    | Unvalidated String
    | Valid String
    | Invalid String (List error)


type alias EmailInput =
    FormInput EmailError


type alias PasswordInput =
    FormInput PasswordError


type alias Form =
    { email : EmailInput, password : PasswordInput }


type FormUpdate
    = ChangeEmail String
    | ChangePassword String
    | Submit



-- -- Other FormInput variants
--init : Form
--init =
--    Form (Invalid "invalid@email.com" [ EmailEmpty ]) (Invalid "invalid_password" [ PasswordToLong ])
--init : Form
--init =
--    Form (Valid "valid@email.com") (Valid "valid_password")


init : Form
init =
    Form (Empty "") (Empty "")



-------------------------------------------------------------------------------
-- VIEW
-------------------------------------------------------------------------------


view : Form -> Html FormUpdate
view { email, password } =
    form []
        [ viewEmailLabel
        , br [] []
        , viewEmailInput email
        , br [] []
        , viewPasswordLabel
        , br [] []
        , viewPasswordInput password
        , br [] []
        , viewSubmitInput
        ]


viewEmailLabel : Html FormUpdate
viewEmailLabel =
    label [ for "email" ] [ text "Email" ]


viewEmailInput : EmailInput -> Html FormUpdate
viewEmailInput email =
    case email of
        Empty default ->
            viewEmailInputDefault default

        Valid data ->
            viewEmailInputValid data

        Invalid data errors ->
            viewEmailInputInvalid data errors

        Unvalidated data ->
            viewEmailInputDefault data


viewEmailInputDefault : String -> Html FormUpdate
viewEmailInputDefault data =
    input [ onInput ChangeEmail, type_ "text", id "email", placeholder "enter your email", value data ] []


viewEmailInputValid : String -> Html FormUpdate
viewEmailInputValid data =
    input [ onInput ChangeEmail, type_ "text", id "email", placeholder "enter your email", value data, style "border" "3px solid rgb(0, 255, 0)", style "background" "rgba(0, 255, 0, 0.2)", style "color" "rgb(0, 255, 0)", readonly True ] []


viewEmailInputInvalid : String -> List EmailError -> Html FormUpdate
viewEmailInputInvalid data errors =
    input [ onInput ChangeEmail, type_ "text", id "email", placeholder "enter your email", value data, style "border" "3px solid rgb(255, 0, 0)", style "background" "rgba(255, 0, 0, 0.2)", style "color" "rgb(255, 0, 0)", readonly True ] []


viewPasswordLabel : Html FormUpdate
viewPasswordLabel =
    label [ for "password" ] [ text "Password" ]


viewPasswordInput : PasswordInput -> Html FormUpdate
viewPasswordInput password =
    case password of
        Empty default ->
            viewPasswordInputDefault default

        Valid data ->
            viewPasswordInputValid data

        Invalid data errors ->
            viewPasswordInputInvalid data errors

        Unvalidated data ->
            viewPasswordInputDefault data


viewPasswordInputDefault : String -> Html FormUpdate
viewPasswordInputDefault data =
    input [ onInput ChangePassword, type_ "text", id "password", placeholder "enter your password", value data ] []


viewPasswordInputValid : String -> Html FormUpdate
viewPasswordInputValid data =
    input [ onInput ChangePassword, type_ "text", id "password", placeholder "enter your password", value data, style "border" "3px solid rgb(0, 255, 0)", style "background" "rgba(0, 255, 0, 0.2)", style "color" "rgb(0, 255, 0)", readonly True ] []


viewPasswordInputInvalid : String -> List PasswordError -> Html FormUpdate
viewPasswordInputInvalid data errors =
    input [ onInput ChangePassword, type_ "text", id "password", placeholder "enter your password", value data, style "border" "3px solid rgb(255, 0, 0)", style "background" "rgba(255, 0, 0, 0.2)", style "color" "rgb(255, 0, 0)", readonly True ] []


viewSubmitInput : Html FormUpdate
viewSubmitInput =
    input [ onSubmit Submit, type_ "submit", value "submit" ] []



-------------------------------------------------------------------------------
-- UPDATE
-------------------------------------------------------------------------------


update : FormUpdate -> Form -> Form
update message model =
    case message of
        ChangeEmail email ->
            { model | email = Unvalidated email }

        ChangePassword password ->
            { model | password = Unvalidated password }

        Submit ->
            model


inputToString : FormInput a -> String
inputToString formInput =
    case formInput of
        Empty data ->
            data

        Valid data ->
            data

        Invalid data _ ->
            data

        Unvalidated data ->
            data



-------------------------------------------------------------------------------
