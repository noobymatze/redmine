port module Ports exposing (Msg(..), send)

import Json.Encode as Encode exposing (Value)
import Session exposing (Session)



-- MSG


type Msg
    = Authenticated Session


encodeMsg : Msg -> Value
encodeMsg msg =
    case msg of
        Authenticated session ->
            Encode.object
                [ ( "type", Encode.string "Authenticated" )
                , ( "session", Session.encode session )
                ]



-- SEND


send : Msg -> Cmd msg
send msg =
    outgoing (encodeMsg msg)


port outgoing : Value -> Cmd msg
