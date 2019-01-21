module Data.TimeEntry exposing (TimeEntry, decoder)

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



-- SERIALIZATION


decoder : Decoder TimeEntry
decoder =
    succeed TimeEntry
        |> required "comments" Decode.string
        |> required "hours" Decode.float
        |> required "spent_on" Decode.string
        |> required "project" Ref.decoder
