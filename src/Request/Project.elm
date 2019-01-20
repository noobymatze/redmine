module Request.Project exposing (all)

import Data.LimitedResult as LimitedResult exposing (LimitedResult)
import Data.Project as Project exposing (Project)
import Data.RemoteData as RemoteData exposing (RemoteData)
import Http
import Json.Decode as Decode exposing (Decoder)
import Request.Authorization as Auth exposing (ApiKey)
import Request.Config exposing (Config)
import Url.Builder as Url
import Url.Builder.Extra as Url



--


{-| Return all projects from Redmine
-}
all : Config -> { offset : Maybe Int, limit : Maybe Int } -> Cmd (RemoteData (LimitedResult Project))
all config { offset, limit } =
    let
        queryParams =
            List.filterMap identity
                [ Url.maybe "offset" Url.int offset
                , Url.maybe "limit" Url.int limit
                , Just (Auth.apiKey "key" config.apiKey)
                ]

        url =
            Url.crossOrigin config.baseUrl [ "projects.json" ] queryParams
    in
    Http.request
        { method = "GET"
        , url = url
        , headers = []
        , body = Http.emptyBody
        , expect = Http.expectJson RemoteData.fromResult (LimitedResult.decoder "projects" Project.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }
