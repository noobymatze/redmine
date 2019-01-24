module Page.Statistics exposing (Model, Msg, init, update, view)

import Browser.Navigation as Nav
import Data.LimitedResult exposing (LimitedResult)
import Data.RemoteData as RemoteData exposing (RemoteData(..))
import Data.Statistics as Stats exposing (HoursAtDay)
import Data.TimeEntry as TimeEntry exposing (TimeEntry)
import Date
import Dict exposing (Dict)
import Html exposing (Html, div, main_, text)
import Html.Attributes exposing (class)
import Http
import LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Range as Range
import LineChart.Axis.Tick as Tick
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Title as Title
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk
import LineChart.Legends as Legends
import LineChart.Line as Line
import Request.Statistics
import Session exposing (Session)
import Time exposing (Month(..))



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
                , limit = Just 100
                , from = Date.fromCalendarDate 2019 Jan 1
                , to = Date.fromCalendarDate 2019 Jan 31
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
    LineChart.viewCustom
        { y = y
        , x = x
        , container = Container.spaced "line-chart-area" 30 100 60 70
        , interpolation = Interpolation.monotone
        , intersection = Intersection.default
        , legends = Legends.default
        , events = Events.default
        , junk = Junk.default
        , grid = Grid.default
        , area = Area.default
        , line = Line.default
        , dots = Dots.default
        }
        [ entries
            |> Stats.hoursSpentPerDay
            |> LineChart.line Colors.purpleLight Dots.circle "Stunden/Tag"
        , entries
            |> Stats.cumulatedHoursSpentPerDay
            |> LineChart.line Colors.blueLight Dots.circle "Kum. Stunden/Tag"
        ]


y : Axis.Config HoursAtDay Msg
y =
    Axis.custom
        { title = Title.default "Hours"
        , variable = Just << .hours
        , pixels = 800
        , range = Range.padded 20 20
        , axisLine = AxisLine.full Colors.gray
        , ticks = Ticks.int 10
        }


x : Axis.Config HoursAtDay Msg
x =
    Axis.custom
        { title = Title.default "Day"
        , variable = Just << .day
        , pixels = 1270
        , range = Range.padded 20 20
        , axisLine = AxisLine.full Colors.gray
        , ticks = Ticks.intCustom 20 tickDay
        }


tickDay : Int -> Tick.Config Msg
tickDay i =
    let
        label =
            i |> String.fromInt |> String.padLeft 2 '0'
    in
    Tick.custom
        { position = toFloat i
        , color = Colors.gray
        , width = 1
        , length = 5
        , grid = False
        , direction = Tick.negative
        , label = Just (Junk.label Colors.black label)
        }



-- UPDATE


type Msg
    = TimeEntriesLoaded (RemoteData (List TimeEntry))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeEntriesLoaded result ->
            ( { model | entries = result }
            , Cmd.none
            )
