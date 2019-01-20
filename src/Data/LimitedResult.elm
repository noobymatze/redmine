module Data.LimitedResult exposing (LimitedResult, decoder)

import Json.Decode as Decode exposing (Decoder, succeed)
import Json.Decode.Pipeline as Decode exposing (required)



-- LIMITED RESULT


type alias LimitedResult a =
    { offset : Int
    , limit : Int
    , total : Int
    , data : List a
    }



-- SERIALIZATION


decoder : String -> Decoder a -> Decoder (LimitedResult a)
decoder field dec =
    succeed LimitedResult
        |> required "offset" Decode.int
        |> required "limit" Decode.int
        |> required "total_count" Decode.int
        |> required field (Decode.list dec)
