module Request.ApiKey exposing (ApiKey(..), apiKey, decoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Url.Builder as Url exposing (QueryParameter)



-- API KEY


type ApiKey
    = ApiKey String



-- PUBLIC HELPERS


apiKey : String -> ApiKey -> QueryParameter
apiKey name (ApiKey key) =
    Url.string name key



-- SERIALIZATION


encode : ApiKey -> Value
encode (ApiKey key) =
    Encode.string key


decoder : Decoder ApiKey
decoder =
    Decode.string
        |> Decode.map ApiKey
