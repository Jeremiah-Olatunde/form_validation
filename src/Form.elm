module Form exposing (..)

import Browser
import Html exposing (Html, br, button, div, form, input, label, li, text, ul)
import Html.Attributes exposing (for, id, placeholder, readonly, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Regex


main =
    Browser.sandbox
        { init = Form (Empty "") (Empty "")
        , view = view
        , update = update
        }



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
{--
    different inputs have different errors
    hence form input is parameterized over error

    each variant contains a value
    for Empty the value is the default
    for all other variants it is the value inputed by the user

    the invalid variant also contains a list of error specific to an input field

    consider parameterizing over input type (e.g text, password)
    perhaps it would make more sense to have different types for each input type (e.g FormInputText, FormInputPassword)
--}


type FormInput error
    = Empty String -- default value
    | Unvalidated String
    | Valid String
    | Invalid String (List error)


type PasswordError
    = PasswordEmpty
    | PasswordToShort
    | PasswordToLong
    | PasswordHasNoSymbols
    | PasswordHasNoNumbers
    | PasswordHasNoCapitalLetters


type EmailError
    = EmailEmpty
    | EmailInvalid


type alias EmailInput =
    FormInput EmailError


type alias PasswordInput =
    FormInput PasswordError


type alias Form =
    { email : EmailInput, password : PasswordInput }


type alias ValidatedForm =
    Result Form Credentials



{--
    FormUpdate is the message type

    since the goal is to model server side form validation, validation will only occur on the Sumbit message
    this message would be analogous to sending a http request with the form data as the body

    ChangeEmail and ChangePassword are required to actually input the data into the field in elm
    and do not currently model anything ssr related

    but the could be used to model live server side validation on user input
--}


type FormUpdate
    = ChangeEmail String
    | ChangePassword String
    | Submit



-------------------------------------------------------------------------------
-- VIEW
-------------------------------------------------------------------------------


view : Form -> Html FormUpdate
view { email, password } =
    div []
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



-- Choose which view to render based on the variant
-- note the similarities between the views in the email input and the password input
-- the differing values are the type, id, placeholder, the label text and data
-- the similarites would be significantly more between say an email input and a slider input


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
    input [ onInput ChangeEmail, type_ "text", id "email", placeholder "enter your email", value data, style "border" "3px solid rgb(0, 255, 0)", style "background" "rgba(0, 255, 0, 0.2)", style "color" "rgb(0, 255, 0)" ] []


viewEmailInputInvalid : String -> List EmailError -> Html FormUpdate
viewEmailInputInvalid data errors =
    div []
        [ input [ onInput ChangeEmail, type_ "text", id "email", placeholder "enter your email", value data, style "border" "3px solid rgb(255, 0, 0)", style "background" "rgba(255, 0, 0, 0.2)", style "color" "rgb(255, 0, 0)" ] []
        , ul [] (List.map viewEmailError errors)
        ]


viewEmailError : EmailError -> Html FormUpdate
viewEmailError error =
    case error of
        EmailEmpty ->
            li [ style "color" "rgb(255, 0, 0)" ] [ text "email can not be empty" ]

        EmailInvalid ->
            li [ style "color" "rgb(255, 0, 0)" ] [ text "email is not valid" ]


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
    input [ onInput ChangePassword, type_ "text", id "password", placeholder "enter your password", value data, style "border" "3px solid rgb(0, 255, 0)", style "background" "rgba(0, 255, 0, 0.2)", style "color" "rgb(0, 255, 0)" ] []


viewPasswordInputInvalid : String -> List PasswordError -> Html FormUpdate
viewPasswordInputInvalid data errors =
    div []
        [ input [ onInput ChangePassword, type_ "text", id "password", placeholder "enter your password", value data, style "border" "3px solid rgb(255, 0, 0)", style "background" "rgba(255, 0, 0, 0.2)", style "color" "rgb(255, 0, 0)" ] []
        , ul [] (List.map viewPasswordError errors)
        ]



-- covert a password error to the li item element


viewPasswordError : PasswordError -> Html FormUpdate
viewPasswordError error =
    case error of
        PasswordEmpty ->
            li [ style "color" "rgb(255, 0, 0)" ] [ text "password can not be empty" ]

        PasswordToShort ->
            li [ style "color" "rgb(255, 0, 0)" ] [ text "password must be greater than 5 characters" ]

        PasswordToLong ->
            li [ style "color" "rgb(255, 0, 0)" ] [ text "password must be less than 10 characters" ]

        PasswordHasNoSymbols ->
            li [ style "color" "rgb(255, 0, 0)" ] [ text "password must contain at least one symbol" ]

        PasswordHasNoNumbers ->
            li [ style "color" "rgb(255, 0, 0)" ] [ text "password must contain at least one number" ]

        PasswordHasNoCapitalLetters ->
            li [ style "color" "rgb(255, 0, 0)" ] [ text "password must contain at least one capital letter" ]


viewSubmitInput : Html FormUpdate
viewSubmitInput =
    button [ onClick Submit ] [ text "submit" ]



-- maintain the state of the input as the user updates the value
-- i.e if a password input is (Invalid value old_error) when the user types in the input
-- and the ChangePassword new_input event is dispacted to the update
-- return (Invalid new_input old_errors)
-- note that if an input was originally Empty value, Unvalidated new_value is returned
-- modeling the fact that once an input is edited it is not considered empty


inputReplaceValue : String -> FormInput a -> FormInput a
inputReplaceValue value formInput =
    case formInput of
        Empty _ ->
            Unvalidated value

        Valid _ ->
            Valid value

        Unvalidated _ ->
            Unvalidated value

        Invalid _ errors ->
            Invalid value errors



-------------------------------------------------------------------------------
-- UPDATE
-------------------------------------------------------------------------------


update : FormUpdate -> Form -> Form
update message { email, password } =
    case message of
        ChangeEmail newValue ->
            { email = inputReplaceValue newValue email
            , password = password
            }

        ChangePassword newValue ->
            { email = email
            , password = inputReplaceValue newValue password
            }

        Submit ->
            { email = validateEmail <| inputToString <| email
            , password = validatePassword <| inputToString <| password
            }



-- all the variants have a similar structure i.e Variant data
-- there must be some operation to take advantage of this to extract the data
-- for now this is fine


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


validateForm : Form -> ValidatedForm
validateForm { email, password } =
    let
        validatedEmail =
            validateEmail <| inputToString <| email

        validatedPassword =
            validatePassword <| inputToString <| password
    in
    case validatedEmail of
        Valid e ->
            case validatedPassword of
                Valid p ->
                    Ok { email = e, password = p }

                _ ->
                    Err { email = validatedEmail, password = validatedPassword }

        _ ->
            Err { email = validatedEmail, password = validatedPassword }


validatePassword : String -> FormInput PasswordError
validatePassword password =
    let
        errors =
            []
                |> passwordIsNotEmpty password
                |> passwordIsLongEnough password
                |> passwordIsShortEnough password
                |> passwordHasNumber password
                |> passwordHasSymbol password
                |> passwordHasCapitalLetter password
    in
    if List.isEmpty errors then
        Valid password

    else
        Invalid password errors


passwordIsShortEnough : String -> List PasswordError -> List PasswordError
passwordIsShortEnough password errors =
    if String.length password > 10 then
        PasswordToLong :: errors

    else
        errors


passwordIsLongEnough : String -> List PasswordError -> List PasswordError
passwordIsLongEnough password errors =
    if String.length password < 5 then
        PasswordToShort :: errors

    else
        errors


passwordHasNumber : String -> List PasswordError -> List PasswordError
passwordHasNumber password errors =
    if not (containsNumber password) then
        PasswordHasNoNumbers :: errors

    else
        errors


passwordHasSymbol : String -> List PasswordError -> List PasswordError
passwordHasSymbol password errors =
    if not (containsSymbol password) then
        PasswordHasNoSymbols :: errors

    else
        errors


passwordHasCapitalLetter : String -> List PasswordError -> List PasswordError
passwordHasCapitalLetter password errors =
    if not (containsCapitalLetter password) then
        PasswordHasNoCapitalLetters :: errors

    else
        errors


containsNumber : String -> Bool
containsNumber =
    Regex.contains (Maybe.withDefault Regex.never <| Regex.fromString "[0-9]")


containsCapitalLetter : String -> Bool
containsCapitalLetter =
    Regex.contains (Maybe.withDefault Regex.never <| Regex.fromString "[A-Z]")


containsSymbol : String -> Bool
containsSymbol =
    Regex.contains (Maybe.withDefault Regex.never <| Regex.fromString "[!@#$%^&*()]")


passwordIsNotEmpty : String -> List PasswordError -> List PasswordError
passwordIsNotEmpty password errors =
    if not (String.isEmpty password) then
        errors

    else
        PasswordEmpty :: errors


validateEmail : String -> FormInput EmailError
validateEmail email =
    let
        errors =
            [] |> emailIsNotEmpty email |> matchesEmailRegex email
    in
    if List.isEmpty errors then
        Valid email

    else
        Invalid email errors


emailIsNotEmpty : String -> List EmailError -> List EmailError
emailIsNotEmpty email errors =
    if not (String.isEmpty email) then
        errors

    else
        EmailEmpty :: errors


matchesEmailRegex : String -> List EmailError -> List EmailError
matchesEmailRegex email errors =
    if isValidEmail email then
        errors

    else
        EmailInvalid :: errors


isValidEmail : String -> Bool
isValidEmail =
    Regex.contains (Maybe.withDefault Regex.never <| Regex.fromString "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")



-------------------------------------------------------------------------------
