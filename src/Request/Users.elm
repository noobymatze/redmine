module Request.Users exposing (find)

import Data.LimitedResult as LimitedResult
import Data.RemoteData as RemoteData exposing (RemoteData)
import Data.User as User exposing (User)
import Http
import Json.Decode as Decode
import Request.Config exposing (Config)
import Url.Builder as Url



-- SEARCH USERS


find : Config -> { login : String } -> Cmd (Result Http.Error (Maybe User))
find config { login } =
    let
        decoder =
            User.decoder
                |> LimitedResult.decoder "users"
                |> Decode.map .data
                |> Decode.map List.head

        params =
            [ Url.string "name" login
            ]

        url =
            Url.crossOrigin config.baseUrl [ "users.json" ] params
    in
    Http.request
        { method = "GET"
        , url = config.baseUrl
        , headers = []
        , body = Http.emptyBody
        , expect = Http.expectJson identity decoder
        , timeout = Nothing
        , tracker = Nothing
        }
