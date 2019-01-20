module Data.TimeEntry exposing (TimeEntry, decoder, groupByDay)

import Data.Project.Ref as Ref exposing (Ref)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, succeed)
import Json.Decode.Pipeline as Decode exposing (required)



-- TIME ENTRY


type alias TimeEntry =
    { comments : String
    , hours : Float
    , spentOn : String
    , project : Ref
    }



-- PUBLIC HELPERS


groupByDay : List TimeEntry -> Dict String (List TimeEntry)
groupByDay entries =
    let
        combine : TimeEntry -> Dict String (List TimeEntry) -> Dict String (List TimeEntry)
        combine next =
            Dict.update next.spentOn
                (\maybeValue ->
                    case maybeValue of
                        Nothing ->
                            Just [ next ]

                        Just list ->
                            Just (next :: list)
                )
    in
    entries
        |> List.foldl combine Dict.empty



-- SERIALIZATION


decoder : Decoder TimeEntry
decoder =
    succeed TimeEntry
        |> required "comments" Decode.string
        |> required "hours" Decode.float
        |> required "spent_on" Decode.string
        |> required "project" Ref.decoder
