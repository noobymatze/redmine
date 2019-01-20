module Url.Builder.Extra exposing (maybe)

import Url.Builder as Url exposing (QueryParameter)


maybe : String -> (String -> a -> QueryParameter) -> Maybe a -> Maybe QueryParameter
maybe field f maybeValue =
    case maybeValue of
        Nothing ->
            Nothing

        Just value ->
            Just (f field value)
