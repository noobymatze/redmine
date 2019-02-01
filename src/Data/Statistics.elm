module Data.Statistics exposing (HoursAtDay, cumulatedHoursSpentPerDay, hoursSpentPerDay, hoursSpentPerWeekDay)

import Data.Project exposing (Project)
import Data.TimeEntry exposing (TimeEntry)
import Date exposing (Date)
import Dict exposing (Dict)
import List.Extra as List
import Set exposing (Set)



-- HOURS PER DAY


type alias HoursAtDay =
    { day : Float
    , hours : Float
    }


hoursSpentPerDay : List TimeEntry -> List HoursAtDay
hoursSpentPerDay entries =
    let
        dayOf date =
            date
                |> String.slice -2 (String.length date)
                |> String.toFloat

        toHoursPerDay ( date, entriesOfDay ) =
            dayOf date
                |> Maybe.map
                    (\day ->
                        { day = day
                        , hours = entriesOfDay |> List.map .hours |> List.sum
                        }
                    )
    in
    entries
        |> List.groupBy .spentOn
        |> Dict.toList
        |> List.filterMap toHoursPerDay



-- WEEK DAYS


type alias HoursAtWeekDay =
    { day : Float
    , hours : Float
    }


hoursSpentPerWeekDay : List TimeEntry -> List HoursAtDay
hoursSpentPerWeekDay entries =
    let
        dayOf date =
            date
                |> Date.fromIsoString
                |> Result.toMaybe
                |> Maybe.map Date.weekdayNumber
                |> Maybe.map toFloat

        toHoursPerDay ( date, entriesOfDay ) =
            dayOf date
                |> Maybe.map
                    (\day ->
                        { day = day
                        , hours = entriesOfDay |> List.map .hours |> List.sum
                        }
                    )
    in
    entries
        |> List.groupBy .spentOn
        |> Dict.toList
        |> List.filterMap toHoursPerDay


cumulatedHoursSpentPerDay : List TimeEntry -> List HoursAtDay
cumulatedHoursSpentPerDay entries =
    let
        cumulate total hoursAtDay =
            ( { hoursAtDay | hours = total + hoursAtDay.hours }
            , total + hoursAtDay.hours
            )
    in
    entries
        |> hoursSpentPerDay
        |> List.mapAccumL cumulate 0.0
