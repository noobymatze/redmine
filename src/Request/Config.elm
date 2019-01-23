module Request.Config exposing (Config, decoder, encode)

import Json.Decode as Decode exposing (Decoder, succeed)
import Json.Decode.Pipeline as Decode exposing (required)
import Json.Encode as Encode exposing (Value)
import Request.ApiKey as ApiKey exposing (ApiKey)



-- CONFIG


type alias Config =
    { apiKey : ApiKey
    , baseUrl : String
    }



-- SERIALIZATION


encode : Config -> Value
encode config =
    Encode.object
        [ ( "apiKey", ApiKey.encode config.apiKey )
        , ( "baseUrl", Encode.string config.baseUrl )
        ]


decoder : Decoder Config
decoder =
    succeed Config
        |> required "apiKey" ApiKey.decoder
        |> required "baseUrl" Decode.string
