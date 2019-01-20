module Data.Project exposing (Project, decoder)

import Data.Project.Ref as Ref exposing (Ref)
import Json.Decode as Decode exposing (Decoder, succeed)
import Json.Decode.Pipeline as Decode exposing (optional, required)



-- PROJECT


type alias Project =
    { id : Int
    , identifier : String
    , name : String
    , description : String
    , createdOn : String
    , updatedOn : String
    , parent : Maybe Ref
    }



-- SERIALIZATION


decoder : Decoder Project
decoder =
    succeed Project
        |> required "id" Decode.int
        |> required "identifier" Decode.string
        |> required "name" Decode.string
        |> required "description" Decode.string
        |> required "created_on" Decode.string
        |> required "updated_on" Decode.string
        |> optional "parent" (Decode.map Just Ref.decoder) Nothing
