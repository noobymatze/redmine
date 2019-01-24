module Page.Login exposing (ExternalMsg(..), Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Data.User exposing (User)
import Dict exposing (Dict)
import Html exposing (Html, button, div, form, h1, input, label, main_, span, text)
import Html.Attributes exposing (class, classList, name, type_, value)
import Html.Events exposing (custom, onInput)
import Http
import Json.Decode as Json
import Request.ApiKey exposing (ApiKey(..))
import Request.Users
import Validate exposing (Validator, ifBlank)



-- MODEL


type LoginState
    = Input
    | Requesting
    | Successful User
    | Failed Http.Error
    | NotFound


type alias Model =
    { baseUrl : String
    , apiKey : String
    , username : String
    , errors : Dict String String
    , state : LoginState
    , navKey : Nav.Key
    }


init : Nav.Key -> ( Model, Cmd Msg )
init navKey =
    ( { baseUrl = ""
      , apiKey = ""
      , username = ""
      , errors = Dict.empty
      , state = Input
      , navKey = navKey
      }
    , Cmd.none
    )



-- VALIDATION


validator : Validator ( String, String ) Model
validator =
    Validate.all
        [ ifBlank .baseUrl ( "baseUrl", "Please insert the URL for your Redmine installation." )
        , ifBlank .apiKey ( "apiKey", "Please insert your personal API-Key. It will be used to authenticate yourself." )
        , ifBlank .username ( "username", "Please insert your login name, so we can find you." )
        ]


validate : Model -> Result (List ( String, String )) (Validate.Valid Model)
validate model =
    model
        |> Validate.validate validator



-- VIEW


view : Model -> Html Msg
view model =
    main_
        [ class "page page--login" ]
        [ h1 [] [ text "Redmine | Login" ]
        , form
            [ class "form form--login" ]
            [ field "Base URL"
                "base-url"
                model.errors
                [ input
                    [ type_ "text"
                    , name "baseUrl"
                    , value model.baseUrl
                    , onInput SetBaseUrl
                    ]
                    []
                ]
            , field "API Key"
                "api-key"
                model.errors
                [ input
                    [ type_ "text"
                    , name "apiKey"
                    , value model.apiKey
                    , onInput SetApiKey
                    ]
                    []
                ]
            , field "Username"
                "username"
                model.errors
                [ input
                    [ type_ "text"
                    , name "username"
                    , value model.username
                    , onInput SetUsername
                    ]
                    []
                ]
            , div
                [ class "form__field form__buttons" ]
                [ button
                    [ custom "click" (Json.succeed { message = Submit, stopPropagation = False, preventDefault = True }) ]
                    [ text "Sign in" ]
                ]
            ]
        ]


field : String -> String -> Dict String String -> List (Html Msg) -> Html Msg
field fieldLabel fieldName errors inputs =
    let
        maybeError =
            errors
                |> Dict.get fieldName

        hasError =
            maybeError
                |> Maybe.map (always True)
                |> Maybe.withDefault False
    in
    div
        [ classList
            [ ( "form__field form__field--" ++ fieldName, True )
            , ( "form__field--error", hasError )
            ]
        ]
        (List.concatMap identity
            [ [ label [] [ text fieldLabel ] ]
            , inputs
            , case maybeError of
                Nothing ->
                    [ span [ class "error error--hidden" ] []
                    ]

                Just error ->
                    [ span [ class "error" ] [ text error ]
                    ]
            ]
        )



-- UPDATE


type ExternalMsg
    = Authenticated { baseUrl : String, apiKey : ApiKey, user : User }
    | None


type Msg
    = SetBaseUrl String
    | SetApiKey String
    | SetUsername String
    | Submit
    | AuthLoaded (Result Http.Error (Maybe User))


update : Msg -> Model -> ( Model, Cmd Msg, ExternalMsg )
update msg model =
    case msg of
        SetBaseUrl string ->
            ( { model | baseUrl = string }
            , Cmd.none
            , None
            )

        SetApiKey string ->
            ( { model | apiKey = string }
            , Cmd.none
            , None
            )

        SetUsername string ->
            ( { model | username = string }
            , Cmd.none
            , None
            )

        AuthLoaded (Err error) ->
            ( { model | state = Failed error }
            , Cmd.none
            , None
            )

        AuthLoaded (Ok (Just user)) ->
            ( { model | state = Successful user }
            , Cmd.none
            , Authenticated
                { apiKey = ApiKey model.apiKey
                , user = user
                , baseUrl = model.baseUrl
                }
            )

        AuthLoaded (Ok Nothing) ->
            ( { model | state = NotFound }
            , Cmd.none
            , None
            )

        Submit ->
            case validate model of
                Err errors ->
                    ( { model | errors = Dict.fromList errors }
                    , Cmd.none
                    , None
                    )

                Ok _ ->
                    ( model
                    , authenticate model
                    , None
                    )



-- COMMANDS


authenticate : Model -> Cmd Msg
authenticate model =
    let
        config =
            { apiKey = ApiKey model.apiKey
            , baseUrl = model.baseUrl
            }
    in
    Cmd.map AuthLoaded <|
        Request.Users.find config
            { login = model.username
            }
