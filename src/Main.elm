module Main exposing (main)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Html exposing (Html, div, text)
import Json.Decode as Json
import Page.Issues as Issues
import Page.Login as Login
import Page.Projects as Projects
import Page.Statistics as Statistics
import Page.Time as Time
import Ports
import Request.ApiKey exposing (ApiKey(..))
import Route exposing (Route(..))
import Session exposing (Session)
import Url exposing (Url)
import Views.Header as Header



-- MAIN


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }



-- MODEL


type alias Flags =
    { session : Maybe String
    }


type Model
    = Blank Nav.Key (Maybe Session)
    | NotFound Nav.Key Session
    | Projects Projects.Model
    | Statistics Statistics.Model
    | Issues Issues.Model
    | Login Login.Model
    | AuthenticatedLogin Session Login.Model
    | Time Time.Model


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        maybeSession =
            flags.session
                |> Maybe.map (Json.decodeString Session.decoder)
                |> Maybe.andThen Result.toMaybe
    in
    ( Blank key maybeSession
    , Nav.pushUrl key <|
        Route.toString <|
            Maybe.withDefault Route.Login <|
                Maybe.map (always Route.Projects) maybeSession
    )


toSession : Model -> ( Nav.Key, Maybe Session )
toSession model =
    case model of
        Blank key maybeSession ->
            ( key, maybeSession )

        NotFound key session ->
            ( key, Just session )

        Projects subModel ->
            ( subModel.navKey, Just subModel.session )

        Statistics subModel ->
            ( subModel.navKey, Just subModel.session )

        Login subModel ->
            ( subModel.navKey, Nothing )

        AuthenticatedLogin session subModel ->
            ( subModel.navKey, Just session )

        Issues subModel ->
            ( subModel.navKey
            , Just subModel.session
            )

        Time subModel ->
            ( subModel.navKey
            , Just subModel.session
            )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model of
        Blank _ _ ->
            { title = "Loading"
            , body =
                [ Header.view
                ]
            }

        NotFound _ _ ->
            { title = "Not found"
            , body =
                [ Header.view
                , div [] [ text "404, not found" ]
                ]
            }

        Projects subModel ->
            { title = "Projects | Redmine"
            , body =
                [ Header.view
                , Projects.view subModel
                    |> Html.map ProjectsMsg
                ]
            }

        Statistics subModel ->
            { title = "Statistics | Redmine"
            , body =
                [ Header.view
                , Statistics.view subModel
                    |> Html.map StatisticsMsg
                ]
            }

        Login subModel ->
            { title = "Login | Redmine"
            , body =
                [ Login.view subModel
                    |> Html.map LoginMsg
                ]
            }

        AuthenticatedLogin _ subModel ->
            { title = "Login | Redmine"
            , body =
                [ Login.view subModel
                    |> Html.map LoginMsg
                ]
            }

        Issues subModel ->
            { title = "Issues | Redmine"
            , body =
                [ Header.view
                , Issues.view subModel
                    |> Html.map IssuesMsg
                ]
            }

        Time subModel ->
            { title = "Issues | Redmine"
            , body =
                [ Header.view
                , Time.view subModel
                    |> Html.map TimeMsg
                ]
            }



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | ProjectsMsg Projects.Msg
    | StatisticsMsg Statistics.Msg
    | IssuesMsg Issues.Msg
    | LoginMsg Login.Msg
    | TimeMsg Time.Msg


changeRouteTo : Route -> Model -> ( Model, Cmd Msg )
changeRouteTo route model =
    let
        ( navKey, maybeSession ) =
            toSession model
    in
    case ( route, maybeSession ) of
        ( Route.Issues, Just session ) ->
            Issues.init navKey session
                |> updateWith Issues IssuesMsg model

        ( Route.Time, Just session ) ->
            Time.init navKey session
                |> updateWith Time TimeMsg model

        ( Route.Issue int, Just session ) ->
            ( Blank navKey (Just session), Cmd.none )

        ( Route.Projects, Just session ) ->
            Projects.init navKey session
                |> updateWith Projects ProjectsMsg model

        ( Route.Statistics, Just session ) ->
            Statistics.init navKey session
                |> updateWith Statistics StatisticsMsg model

        ( Route.NotFound, Just session ) ->
            ( NotFound navKey session, Cmd.none )

        ( Route.Login, _ ) ->
            Login.init navKey
                |> updateWith Login LoginMsg model

        ( _, Nothing ) ->
            Login.init navKey
                |> updateWith Login LoginMsg model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    let
                        ( navKey, _ ) =
                            toSession model
                    in
                    ( model
                    , Nav.pushUrl navKey (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ProjectsMsg subMsg, Projects subModel ) ->
            Projects.update subMsg subModel
                |> updateWith Projects ProjectsMsg model

        ( StatisticsMsg subMsg, Statistics subModel ) ->
            Statistics.update subMsg subModel
                |> updateWith Statistics StatisticsMsg model

        ( IssuesMsg subMsg, Issues subModel ) ->
            Issues.update subMsg subModel
                |> updateWith Issues IssuesMsg model

        ( TimeMsg subMsg, Time subModel ) ->
            Time.update subMsg subModel
                |> updateWith Time TimeMsg model

        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( newSubModel, subCmd, externalMsg ) =
                    Login.update subMsg subModel
            in
            case externalMsg of
                Login.Authenticated record ->
                    let
                        newSession =
                            { env =
                                { api =
                                    { apiKey = record.apiKey
                                    , baseUrl = record.baseUrl
                                    }
                                }
                            , user = Just record.user
                            }

                        ( newModel, cmd ) =
                            changeRouteTo Route.Projects (AuthenticatedLogin newSession newSubModel)
                    in
                    ( newModel
                    , Cmd.batch
                        [ Cmd.map LoginMsg subCmd
                        , cmd
                        , Ports.send (Ports.Authenticated newSession)
                        ]
                    )

                Login.None ->
                    ( Login newSubModel
                    , Cmd.map LoginMsg subCmd
                    )

        -- Discard any incoming message, which doesn't fit
        ( _, _ ) ->
            ( model
            , Cmd.none
            )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- SUBSCRITPIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
