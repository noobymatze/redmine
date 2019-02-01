module Data.Issue exposing (Issue, decoder, href)

import Data.Project.Ref as Project
import Data.User.Ref as User
import Html exposing (Attribute)
import Html.Attributes as Attr
import Json.Decode as Decode exposing (Decoder, succeed)
import Json.Decode.Extra exposing (maybe)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Request.Config exposing (Config)
import Url.Builder as Url



-- ISSUE


type alias Issue =
    { id : Int
    , project : Project.Ref
    , subject : String
    , author : User.Ref
    , description : String
    , startDate : String
    , doneRatio : Int
    , estimatedHours : Maybe Float
    , createdOn : String
    , updatedOn : String
    }



-- PUBLIC HELPERS


href : Config -> Issue -> Attribute msg
href config issue =
    Attr.href (Url.crossOrigin config.baseUrl [ "issues", String.fromInt issue.id ] [])



-- SERIALIZATION


decoder : Decoder Issue
decoder =
    succeed Issue
        |> required "id" Decode.int
        |> required "project" Project.decoder
        |> required "subject" Decode.string
        |> required "author" User.decoder
        |> required "description" Decode.string
        |> required "start_date" Decode.string
        |> required "done_ratio" Decode.int
        |> maybe "estimated_hours" Decode.float
        |> required "created_on" Decode.string
        |> required "updated_on" Decode.string
