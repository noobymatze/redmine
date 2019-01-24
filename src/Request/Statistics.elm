module Request.Statistics exposing (timeEntries)

import Data.LimitedResult as LimitedResult exposing (LimitedResult)
import Data.RemoteData as RemoteData exposing (RemoteData)
import Data.TimeEntry as TimeEntry exposing (TimeEntry)
import Date exposing (Date)
import Http exposing (stringResolver)
import Json.Decode as Json
import Request.ApiKey as Auth exposing (ApiKey(..))
import Request.Config exposing (Config)
import Task exposing (Task)
import Url.Builder as Url
import Url.Builder.Extra as Url



-- STATISTICS REQUESTS


timeEntries : Config -> { from : Date, to : Date, offset : Maybe Int, limit : Maybe Int } -> Cmd (RemoteData (List TimeEntry))
timeEntries config data =
    let
        checkForMore : LimitedResult TimeEntry -> Task Http.Error (LimitedResult TimeEntry)
        checkForMore result =
            if result.offset + result.limit >= result.total then
                Task.succeed result

            else
                Task.andThen checkForMore <|
                    Task.map (\l -> { l | data = result.data ++ l.data }) <|
                        timeEntriesHelp config
                            { from = data.from
                            , to = data.to
                            , offset = Just (result.offset + result.limit)
                            , limit = data.limit
                            }
    in
    timeEntriesHelp config data
        |> Task.andThen checkForMore
        |> Task.map .data
        |> Task.attempt RemoteData.fromResult


timeEntriesHelp : Config -> { from : Date, to : Date, offset : Maybe Int, limit : Maybe Int } -> Task Http.Error (LimitedResult TimeEntry)
timeEntriesHelp config { from, to, offset, limit } =
    let
        spentOn =
            String.join ""
                [ "><"
                , Date.toIsoString from
                , "|"
                , Date.toIsoString to
                ]

        queryParams =
            List.filterMap identity
                [ Url.maybe "offset" Url.int offset
                , Url.maybe "limit" Url.int limit
                , Just (Url.string "spent_on" spentOn)
                , Just (Auth.apiKey "key" config.apiKey)
                ]

        url =
            Url.crossOrigin config.baseUrl [ "time_entries.json" ] queryParams

        decoder =
            LimitedResult.decoder "time_entries" TimeEntry.decoder
    in
    Http.task
        { method = "GET"
        , url = url
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        , resolver =
            stringResolver
                (\response ->
                    case response of
                        Http.BadUrl_ value ->
                            Err (Http.BadUrl value)

                        Http.Timeout_ ->
                            Err Http.Timeout

                        Http.NetworkError_ ->
                            Err Http.NetworkError

                        Http.BadStatus_ meta _ ->
                            Err (Http.BadStatus meta.statusCode)

                        Http.GoodStatus_ _ body ->
                            case Json.decodeString decoder body of
                                Err _ ->
                                    Err (Http.BadBody body)

                                Ok value ->
                                    Ok value
                )
        }
