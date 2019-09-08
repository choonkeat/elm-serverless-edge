module Mock.DB exposing
    ( delete
    , read
    , write
    )

{-| returns the VALUE, if successful
-}

import Http
import Json.Decode
import Json.Encode
import Platform exposing (Task)
import Task


read : String -> String -> Json.Decode.Decoder a -> Task Http.Error a
read namespace key decoder =
    Task.fail Http.NetworkError


{-| returns the VALUE you wrote, if successful
-}
write : String -> String -> Json.Encode.Value -> Task Http.Error String
write namespace key value =
    Task.fail Http.NetworkError


{-| returns the KEY you deleted, if successful
-}
delete : String -> String -> Task Http.Error String
delete namespace key =
    Task.fail Http.NetworkError
