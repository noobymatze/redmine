module Data.User exposing (User, decoder, encode)

import Json.Decode as Decode exposing (Decoder, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)



-- USER


type alias User =
    { id : Int
    , login : String
    , firstName : String
    , lastName : String
    , email : String
    , createdOn : String
    , lastLoginOn : String
    }



-- SERIALIZATION


decoder : Decoder User
decoder =
    succeed User
        |> required "id" Decode.int
        |> required "login" Decode.string
        |> required "firstname" Decode.string
        |> required "lastname" Decode.string
        |> required "mail" Decode.string
        |> required "created_on" Decode.string
        |> required "last_login_on" Decode.string


encode : User -> Value
encode user =
    Encode.object
        [ ( "id", Encode.int user.id )
        , ( "login", Encode.string user.login )
        , ( "firstname", Encode.string user.firstName )
        , ( "lastname", Encode.string user.lastName )
        , ( "mail", Encode.string user.email )
        , ( "created_on", Encode.string user.createdOn )
        , ( "last_login_on", Encode.string user.lastLoginOn )
        ]
