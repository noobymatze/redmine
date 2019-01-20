module Request.Authorization exposing (ApiKey(..), apiKey)

import Url.Builder as Url exposing (QueryParameter)



-- AUTHORIZATION WITH API KEY


type ApiKey
    = ApiKey String


apiKey : String -> ApiKey -> QueryParameter
apiKey name (ApiKey key) =
    Url.string name key
