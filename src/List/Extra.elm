module List.Extra exposing (groupBy, mapAccumL)

import Dict exposing (Dict)



-- EXTRA


groupBy : (a -> comparable) -> List a -> Dict comparable (List a)
groupBy f =
    let
        combine next result =
            result
                |> Dict.update (f next)
                    (\maybeValue ->
                        case maybeValue of
                            Nothing ->
                                Just [ next ]

                            Just list ->
                                Just ([ next ] ++ list)
                    )
    in
    List.foldl combine Dict.empty


mapAccumL : (state -> a -> ( b, state )) -> state -> List a -> List b
mapAccumL f empty =
    let
        combine next ( state, result ) =
            let
                ( value, newState ) =
                    f state next
            in
            ( newState, result ++ [ value ] )
    in
    Tuple.second << List.foldl combine ( empty, [] )
