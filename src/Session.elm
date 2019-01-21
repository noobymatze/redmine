module Session exposing (Session, navKey)

import Browser.Navigation as Nav
import Request.Authorization exposing (ApiKey(..))



-- SESSION


type alias Session =
    { navKey : Nav.Key
    , env :
        { api :
            { baseUrl : String
            , apiKey : ApiKey
            }
        }
    }



-- PUBLIC HELPERS


navKey : Session -> Nav.Key
navKey session =
    session.navKey
