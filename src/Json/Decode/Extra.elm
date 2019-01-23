module Json.Decode.Extra exposing (maybe)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional)


maybe : String -> Decoder a -> Decoder (Maybe a -> b) -> Decoder b
maybe name dec =
    optional name (Decode.map Just dec) Nothing
