module Page.Time exposing (Model, Msg(..), chart, init, tickDay, update, view, x, y)

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
import Request.TimeEntries
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
            Request.TimeEntries.getMyTime session.env.api
                { userId = session.user |> Maybe.map .id |> Maybe.withDefault 0
                , today = Date.fromCalendarDate 2019 Feb 1
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
    let
        points =
            Stats.hoursSpentPerWeekDay entries
    in
    Debug.log (Debug.toString points) <|
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
            [ points
                |> LineChart.line Colors.purpleLight Dots.circle "h/day"
            , points
                |> List.length
                |> List.range 1
                |> List.map (\i -> { day = toFloat i, hours = 8.0 })
                |> LineChart.line Colors.gray Dots.circle "normal/day"
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
        , ticks = Ticks.intCustom 7 tickDay
        }


tickDay : Int -> Tick.Config Msg
tickDay i =
    let
        label =
            case Date.numberToWeekday i of
                Time.Mon ->
                    "Mon"

                Time.Tue ->
                    "Tue"

                Time.Wed ->
                    "Wed"

                Time.Thu ->
                    "Thu"

                Time.Fri ->
                    "Fri"

                Time.Sat ->
                    "Sat"

                Time.Sun ->
                    "Sun"
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
            Debug.log (Debug.toString result)
                ( { model | entries = result }
                , Cmd.none
                )
