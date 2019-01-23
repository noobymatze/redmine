module Json.Encode.Extra exposing (maybe)

import Json.Encode as Encode exposing (Value)


maybe : (a -> Value) -> Maybe a -> Value
maybe f maybeValue =
    maybeValue
        |> Maybe.map f
        |> Maybe.withDefault Encode.null
