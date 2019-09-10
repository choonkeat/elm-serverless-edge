module Server.Platform exposing (..)

{-| Apps use this package to handle HTTP requests.
-}

import Runtime.Handler
import Server.HTTP exposing (Body, Headers, Method, Request, StatusCode)


{-| Create a commandline application.

Having this entry point helps evolve our thinking around what "server side Elm"
should be, even though we're using `Platform.worker` underneath for now

-}
application :
    { init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    }
    -> Program flags model msg
application =
    Platform.worker


handleRequest : (Request -> msg) -> Sub msg
handleRequest =
    Runtime.Handler.handleRequest


writeResponse : StatusCode -> Body -> Headers -> Request -> Cmd msg
writeResponse =
    Runtime.Handler.writeResponse
