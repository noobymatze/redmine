module Page.Statistics exposing (Model, Msg, init, update, view)

import Data.LimitedResult exposing (LimitedResult)
import Data.RemoteData as RemoteData exposing (RemoteData(..))
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
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { entries = Loading
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


type alias Point =
    { x : Float
    , y : Float
    }


chart : List TimeEntry -> Html Msg
chart entries =
    let
        getDay date =
            date
                |> String.slice -2 (String.length date)
                |> String.toFloat

        hoursPerDay ( date, entriesOfDay ) =
            case getDay date of
                Nothing ->
                    Nothing

                Just day ->
                    Just
                        { x = day
                        , y = entriesOfDay |> List.map .hours |> List.foldl (+) 0.0
                        }

        cumulatedHoursPerDay ( date, entriesOfDay ) ( cumulated, entryPoints ) =
            case getDay date of
                Nothing ->
                    ( cumulated, entryPoints )

                Just day ->
                    let
                        hoursOfDay =
                            entriesOfDay |> List.map .hours |> List.foldl (+) 0.0
                    in
                    ( cumulated + hoursOfDay
                    , { x = day
                      , y = cumulated + hoursOfDay
                      }
                        :: entryPoints
                    )

        points =
            entries
                |> TimeEntry.groupByDay
                |> Dict.toList
                |> List.filterMap hoursPerDay

        ( _, cumulatedPoints ) =
            entries
                |> TimeEntry.groupByDay
                |> Dict.toList
                |> List.foldl cumulatedHoursPerDay ( 0.0, [] )
    in
    LineChart.view .x
        .y
        [ LineChart.line Colors.purpleLight Dots.circle "Stunden/Tag" points
        , LineChart.line Colors.blueLight Dots.circle "Kum. Stunden/Tag" cumulatedPoints
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
