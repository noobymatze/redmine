module Request.Config exposing (Config)

import Request.Authorization exposing (ApiKey)



-- CONFIG


type alias Config =
    { apiKey : ApiKey
    , baseUrl : String
    }
