module Request.Issues exposing (find)

import Data.Issue as Issue exposing (Issue)
import Data.LimitedResult as LimitedResult exposing (LimitedResult)
import Data.RemoteData as RemoteData exposing (RemoteData)
import Http
import Request.ApiKey as ApiKey exposing (ApiKey(..))
import Request.Config exposing (Config)
import Request.Issues.Filter as Filter exposing (Filter)
import Url.Builder as Url



-- ISSUES


find : Config -> Filter -> Cmd (RemoteData (LimitedResult Issue))
find config filter =
    let
        queryParams =
            filter
                |> Filter.toQuery
                |> List.append [ ApiKey.apiKey "key" config.apiKey ]

        url =
            Url.crossOrigin config.baseUrl [ "issues.json" ] queryParams
    in
    Http.request
        { method = "GET"
        , url = url
        , headers = []
        , body = Http.emptyBody
        , expect = Http.expectJson RemoteData.fromResult (LimitedResult.decoder "issues" Issue.decoder)
        , timeout = Nothing
        , tracker = Nothing
        }
