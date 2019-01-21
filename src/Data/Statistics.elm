module Data.Statistics exposing (HoursAtDay, cumulatedHoursSpentPerDay, hoursSpentPerDay)

import Data.TimeEntry exposing (TimeEntry)
import Dict
import List.Extra as List



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
