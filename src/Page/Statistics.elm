module Page.Statistics exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Data.LimitedResult exposing (LimitedResult)
import Data.RemoteData as RemoteData exposing (RemoteData(..))
import Data.Statistics as Stats
import Data.TimeEntry as TimeEntry exposing (TimeEntry)
import Dict exposing (Dict)
import Html exposing (Html, div, main_, text)
import Html.Attributes exposing (class)
import Http
import LineChart
import LineChart.Colors as Colors
import LineChart.Dots as Dots
import Request.Statistics
import Session exposing (Session)



-- MODEL


type alias Model =
    { entries : RemoteData (List TimeEntry)
    , session : Session
    , navKey : Nav.Key
    }


init : Nav.Key -> Session -> ( Model, Cmd Msg )
init navKey session =
    ( { entries = Loading
      , navKey = navKey
      , session = session
      }
    , Cmd.batch
        [ Cmd.map TimeEntriesLoaded <|
            Request.Statistics.timeEntries session.env.api
                { offset = Nothing
                , limit = Just 2000
                }
        ]
    )



-- VIEW


view : Model -> Html Msg
view model =
    main_ [ class "page page--statistics" ]
        [ RemoteData.view chart model.entries
        ]



-- CHART


chart : List TimeEntry -> Html Msg
chart entries =
    LineChart.view .day
        .hours
        [ entries
            |> Stats.hoursSpentPerDay
            |> LineChart.line Colors.purpleLight Dots.circle "Stunden/Tag"
        , entries
            |> Stats.cumulatedHoursSpentPerDay
            |> LineChart.line Colors.blueLight Dots.circle "Kum. Stunden/Tag"
        ]



-- UPDATE


type Msg
    = TimeEntriesLoaded (RemoteData (LimitedResult TimeEntry))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeEntriesLoaded result ->
            ( { model | entries = RemoteData.map .data result }
            , Cmd.none
            )
