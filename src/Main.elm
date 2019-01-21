module Main exposing (main)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Html exposing (Html, div, text)
import Page.Projects as Projects
import Page.Statistics as Statistics
import Request.Authorization exposing (ApiKey(..))
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
    { http :
        { baseUrl : String
        , apiKey : String
        }
    }


type Model
    = Blank Session
    | NotFound Session
    | Projects Projects.Model
    | Statistics Statistics.Model


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    changeRouteTo (Route.fromUrl url) <|
        Blank
            { navKey = key
            , env =
                { api =
                    { baseUrl = flags.http.baseUrl
                    , apiKey = ApiKey flags.http.apiKey
                    }
                }
            }


toSession : Model -> Session
toSession model =
    case model of
        Blank session ->
            session

        NotFound session ->
            session

        Projects subModel ->
            subModel.session

        Statistics subModel ->
            subModel.session



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model of
        Blank _ ->
            { title = "Loading"
            , body =
                [ Header.view
                ]
            }

        NotFound _ ->
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



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | ProjectsMsg Projects.Msg
    | StatisticsMsg Statistics.Msg


changeRouteTo : Route -> Model -> ( Model, Cmd Msg )
changeRouteTo route model =
    let
        session =
            toSession model
    in
    case route of
        Route.Issues ->
            ( Blank session, Cmd.none )

        Route.Issue int ->
            ( Blank session, Cmd.none )

        Route.Projects ->
            Projects.init session
                |> updateWith Projects ProjectsMsg model

        Route.Statistics ->
            Statistics.init session
                |> updateWith Statistics StatisticsMsg model

        Route.NotFound ->
            ( NotFound session, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Session.navKey (toSession model)) (Url.toString url)
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
