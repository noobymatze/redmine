module Views.Header exposing (view)

import Html exposing (Html, a, header, li, nav, section, text, ul)
import Html.Attributes exposing (class)
import Route exposing (Route(..))



-- VIEW


view : Html msg
view =
    header
        [ class "header" ]
        [ section
            [ class "navigation" ]
            [ nav
                [ class "" ]
                [ ul
                    []
                    [ li [] [ a [ Route.href Projects ] [ text "Projects" ] ]
                    , li [] [ a [ Route.href Issues ] [ text "Issues" ] ]
                    , li [] [ a [ Route.href Time ] [ text "Time" ] ]
                    , li [] [ a [ Route.href Statistics ] [ text "Statistics" ] ]
                    ]
                ]
            ]
        ]
