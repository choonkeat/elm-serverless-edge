module Mock.Handler exposing
    ( handleRequest
    , writeResponse
    )

import Server.HTTP exposing (Body, Headers, Method, Request, StatusCode)


handleRequest : (Request -> msg) -> Sub msg
handleRequest msgTag =
    Sub.none


writeResponse : StatusCode -> Body -> Headers -> Request -> Cmd msg
writeResponse code body headers request =
    Cmd.none
