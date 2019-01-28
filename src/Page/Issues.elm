module Page.Issues exposing (Model, Msg(..), init, update, view)

import Browser.Navigation as Nav
import Data.Issue as Issue exposing (Issue)
import Data.LimitedResult exposing (LimitedResult)
import Data.RemoteData exposing (RemoteData(..))
import Html exposing (Html, a, div, h2, li, main_, text, ul)
import Html.Attributes exposing (class, href)
import Request.Issues
import Request.Issues.Filter as Filter exposing (emptyFilter)
import Session exposing (Session)
import Views.Error as Views



-- MODEL


type alias Model =
    { issues : RemoteData (LimitedResult Issue)
    , navKey : Nav.Key
    , session : Session
    }


init : Nav.Key -> Session -> ( Model, Cmd Msg )
init key session =
    ( { issues = Loading
      , navKey = key
      , session = session
      }
    , Cmd.map IssuesLoaded <|
        Request.Issues.find session.env.api emptyFilter
    )


view : Model -> Html Msg
view model =
    main_
        [ class "page page--issues" ]
        [ case model.issues of
            Loading ->
                text "Loading your issues..."

            Failed error ->
                Views.viewError error

            Loaded issues ->
                viewIssues model.session issues.data
        ]


viewIssues : Session -> List Issue -> Html Msg
viewIssues session issues =
    ul
        [ class "issues" ]
        (List.map (viewIssue session) issues)


viewIssue : Session -> Issue -> Html Msg
viewIssue session issue =
    let
        ellipsis input =
            if String.length input < 150 then
                input

            else
                input
                    |> String.slice 0 150
                    |> (\desc -> desc ++ "...")
    in
    li
        []
        [ h2
            [ class "issue__subject" ]
            [ a
                [ Issue.href session.env.api issue ]
                [ text <|
                    String.join ""
                        [ "[#"
                        , String.fromInt issue.id
                        , "] "
                        , issue.subject
                        ]
                ]
            ]
        , div
            [ class "issue__description" ]
            [ text <| ellipsis issue.description
            ]
        ]



-- UPDATE


type Msg
    = IssuesLoaded (RemoteData (LimitedResult Issue))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IssuesLoaded data ->
            Debug.log (Debug.toString data)
                ( { model | issues = data }
                , Cmd.none
                )
