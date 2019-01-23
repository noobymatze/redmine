module Session exposing (Session, decoder, encode)

import Browser.Navigation as Nav
import Data.User as User exposing (User)
import Json.Decode as Decode exposing (Decoder, succeed)
import Json.Decode.Extra exposing (maybe)
import Json.Decode.Pipeline as Decode exposing (required)
import Json.Encode as Encode exposing (Value)
import Json.Encode.Extra as Encode
import Request.Config as Config exposing (Config)



-- SESSION


type alias Session =
    { user : Maybe User
    , env :
        { api : Config
        }
    }



-- SERIALIZATION


encode : Session -> Value
encode session =
    Encode.object
        [ ( "user", Encode.maybe User.encode session.user )
        , ( "env"
          , Encode.object
                [ ( "api", Config.encode session.env.api )
                ]
          )
        ]


decoder : Decoder Session
decoder =
    let
        decodeEnv =
            Config.decoder
                |> Decode.field "api"
                |> Decode.map (\api -> { api = api })
    in
    succeed Session
        |> maybe "user" User.decoder
        |> required "env" decodeEnv
