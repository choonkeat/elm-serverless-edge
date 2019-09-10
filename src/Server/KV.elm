module Server.KV exposing (..)

{-| Apps use this package to interact with key-value store.
-}

import Http
import Json.Decode
import Json.Encode
import Platform exposing (Task)
import Runtime.KV


type alias Namespace =
    String


type alias Key =
    String


read : Namespace -> Key -> Json.Decode.Decoder a -> Task Http.Error a
read =
    Runtime.KV.read


write : Namespace -> Key -> Json.Encode.Value -> Task Http.Error String
write =
    Runtime.KV.write


delete : Namespace -> Key -> Task Http.Error String
delete =
    Runtime.KV.delete
