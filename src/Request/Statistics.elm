module Request.Statistics exposing (timeEntries)

import Data.LimitedResult as LimitedResult exposing (LimitedResult)
import Data.RemoteData as RemoteData exposing (RemoteData)
import Data.TimeEntry as TimeEntry exposing (TimeEntry)
import Http
import Request.Authorization as Auth exposing (ApiKey(..))
import Request.Config exposing (Config)
import Url.Builder as Url
import Url.Builder.Extra as Url



-- STATISTICS REQUESTS


timeEntries : Config -> { offset : Maybe Int, limit : Maybe Int } -> Cmd (RemoteData (LimitedResult TimeEntry))
timeEntries config { offset, limit } =
    let
        queryParams =
            List.filterMap identity
                [ Url.maybe "offset" Url.int offset
                , Url.maybe "limit" Url.int limit
                , Just (Auth.apiKey "key" config.apiKey)
                ]

        url =
            Url.crossOrigin config.baseUrl [ "time_entries.json" ] queryParams
    in
    Http.request
        { method = "GET"
        , url = url
        , headers = []
        , body = Http.emptyBody
        , expect = Http.expectJson RemoteData.fromResult (LimitedResult.decoder "time_entries" TimeEntry.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }
