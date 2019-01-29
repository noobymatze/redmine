module Data.User.Ref exposing (Ref, decoder)

import Json.Decode as Decode exposing (Decoder, succeed)
import Json.Decode.Pipeline exposing (required)



-- REF


type alias Ref =
    { id : Int
    , name : String
    }



-- SERIALIZATION


decoder : Decoder Ref
decoder =
    succeed Ref
        |> required "id" Decode.int
        |> required "name" Decode.string
