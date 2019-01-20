module Data.RemoteData exposing (RemoteData(..), fromResult, map, view)

import Html exposing (Html, div, text)
import Http
import Views.Error as Views



-- REMOTE STATE


type RemoteData a
    = Loading
    | Loaded a
    | Failed Http.Error



-- PUBLIC HELPERS


map : (a -> b) -> RemoteData a -> RemoteData b
map f data =
    case data of
        Loaded value ->
            Loaded (f value)

        Loading ->
            Loading

        Failed error ->
            Failed error


fromResult : Result Http.Error a -> RemoteData a
fromResult result =
    case result of
        Err error ->
            Failed error

        Ok value ->
            Loaded value


view : (a -> Html msg) -> RemoteData a -> Html msg
view viewValue state =
    case state of
        Loading ->
            div [] [ text "Loading data..." ]

        Loaded a ->
            viewValue a

        Failed error ->
            Views.viewError error
