module Server.DB exposing (..)

{-| Apps use this package to interact with key-value store. Swap `Runtime`
-}

import Http
import Json.Decode
import Json.Encode
import Mock.DB as Runtime
import Platform exposing (Task)


type alias Namespace =
    String


type alias Key =
    String


read : Namespace -> Key -> Json.Decode.Decoder a -> Task Http.Error a
read =
    Runtime.read


write : Namespace -> Key -> Json.Encode.Value -> Task Http.Error String
write =
    Runtime.write


delete : Namespace -> Key -> Task Http.Error String
delete =
    Runtime.delete
