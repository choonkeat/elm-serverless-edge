module Server.Handler exposing (..)

{-| Apps use this package to handle HTTP requests. Swap `Runtime`
-}

import Mock.Handler as Runtime
import Server.HTTP exposing (Body, Headers, Method, Request, StatusCode)


handleRequest : (Request -> msg) -> Sub msg
handleRequest =
    Runtime.handleRequest


writeResponse : StatusCode -> Body -> Headers -> Request -> Cmd msg
writeResponse =
    Runtime.writeResponse
