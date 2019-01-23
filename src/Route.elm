module Route exposing (Route(..), fromUrl, href, parse, toString)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Builder exposing (relative)
import Url.Parser as Url exposing ((</>), s)



-- ROUTE


type Route
    = Login
    | Issues
    | Issue Int
    | Projects
    | Statistics
    | NotFound



-- PRIVATE HELPERS


parser : Url.Parser (Route -> a) a
parser =
    Url.oneOf
        [ Url.map Projects Url.top
        , Url.map Issue (s "issue" </> Url.int)
        , Url.map Login (s "login")
        , Url.map Projects (s "projects")
        , Url.map Statistics (s "statistics")
        , Url.map NotFound (s "404")
        ]



-- PUBLIC HELPERS


href : Route -> Attribute msg
href route =
    Attr.href (toString route)


fromUrl : Url -> Route
fromUrl url =
    Url.parse parser url
        |> Maybe.withDefault NotFound


parse : String -> Route
parse string =
    string
        |> Url.fromString
        |> Maybe.map fromUrl
        |> Maybe.withDefault NotFound


toString : Route -> String
toString route =
    case route of
        Issues ->
            relative [] []

        Issue int ->
            relative [ "issues", String.fromInt int ] []

        Projects ->
            relative [ "projects" ] []

        Statistics ->
            relative [ "statistics" ] []

        NotFound ->
            relative [ "404" ] []

        Login ->
            relative [ "login" ] []
