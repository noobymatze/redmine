module Date.Extra exposing (getCurrentWeek)

import Date exposing (Date, Unit(..))



-- WORKING WITH A WEEK


getCurrentWeek : Date -> ( Date, Date )
getCurrentWeek date =
    let
        weekDay =
            Date.weekdayNumber date

        beginning =
            date
                |> Date.add Days (1 - weekDay)

        end =
            date
                |> Date.add Days (7 - weekDay)
    in
    ( beginning, end )
