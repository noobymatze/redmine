module Page.Projects exposing (Model, Msg, init, update, view)

import Data.LimitedResult exposing (LimitedResult)
import Data.Project exposing (Project)
import Data.RemoteData as RemoteData exposing (RemoteData(..))
import Html exposing (Html, div, h1, li, main_, text, ul)
import Html.Attributes exposing (class)
import Http
import Request.Project
import Session exposing (Session)



-- MODEL


type alias Model =
    { session : Session
    , projects : RemoteData (List Project)
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , projects = Loading
      }
    , Cmd.batch
        [ Cmd.map ProjectsLoaded <|
            Request.Project.all session.http
                { offset = Nothing
                , limit = Nothing
                }
        ]
    )



-- VIEW


view : Model -> Html Msg
view model =
    main_
        [ class "page page--projects" ]
        [ RemoteData.view viewProjects model.projects
        ]


viewProjects : List Project -> Html Msg
viewProjects projects =
    ul
        [ class "projects" ]
        (List.map viewProject projects)


viewProject : Project -> Html Msg
viewProject project =
    li
        [ class "project"
        ]
        [ h1 [ class "project__name" ] [ text project.name ]
        , div [ class "project__description" ] [ text project.description ]
        ]



-- UPDATE


type Msg
    = ProjectsLoaded (RemoteData (LimitedResult Project))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ProjectsLoaded result ->
            ( { model | projects = RemoteData.map .data result }
            , Cmd.none
            )
