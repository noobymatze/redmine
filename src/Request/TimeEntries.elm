module Request.TimeEntries exposing (getMyTime)

import Data.RemoteData as RemoteData exposing (RemoteData)
import Data.TimeEntry as TimeEntry exposing (TimeEntry)
import Date exposing (Date)
import Date.Extra as Date
import Http
import Json.Decode as Decode
import Request.ApiKey as ApiKey
import Request.Config exposing (Config)
import Task
import Url.Builder as Url


{-| -}
getMyTime : Config -> { userId : Int, today : Date } -> Cmd (RemoteData (List TimeEntry))
getMyTime config filter =
    let
        ( beginning, end ) =
            Date.getCurrentWeek filter.today

        params =
            [ ApiKey.apiKey "key" config.apiKey
            , Url.int "user_id" filter.userId
            , Url.int "limit" 100
            , Url.string "spent_on" <| "><" ++ Date.toIsoString beginning ++ "|" ++ Date.toIsoString end
            ]

        url =
            Url.crossOrigin config.baseUrl [ "time_entries.json" ] params

        decoder =
            TimeEntry.decoder
                |> Decode.list
                |> Decode.field "time_entries"
    in
    Http.request
        { method = "GET"
        , url = url
        , headers = []
        , body = Http.emptyBody
        , expect = Http.expectJson RemoteData.fromResult decoder
        , timeout = Nothing
        , tracker = Nothing
        }
