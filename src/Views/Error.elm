module Views.Error exposing (viewError)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Http



-- | View the HTTP error


viewError : Http.Error -> Html msg
viewError error =
    case error of
        Http.BadUrl string ->
            div
                [ class "error error--http error--bad-url" ]
                [ text "Sorry, something went wrong on a technical level."
                ]

        Http.Timeout ->
            div
                [ class "error error--http error--timeout" ]
                [ text "It seems the server is very slow to respond today, try again."
                ]

        Http.NetworkError ->
            div
                [ class "error error--http error--network" ]
                [ text "Are you sure, you are connected to the internet?" ]

        Http.BadStatus int ->
            div
                [ class "error error--http error--bad-status" ]
                [ text "Oops, I could not fetch the data for some reason..." ]

        Http.BadBody string ->
            div
                [ class "error error--http error--bad-body" ]
                [ text "Sorry, something went wrong on a technical level."
                ]
