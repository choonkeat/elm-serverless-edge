module Route exposing (Context(..), Page(..), decodeContext, fromRequest)

import Json.Decode exposing (oneOf)
import Jwt
import Server.HTTP exposing (Method, Request)
import Url
import Url.Parser exposing ((</>), (<?>), map, query, s)
import Url.Parser.Query


type Page
    = NotFound
    | Homepage


{-| This section is the equivalent of common web frameworks' "routes"
-}
router : Url.Parser.Parser (Page -> b) b
router =
    Url.Parser.oneOf
        [ map Homepage Url.Parser.top

        -- , map Status (s "api" </> s "status")
        ]


type Context
    = Anonymous (Maybe Lang) (Maybe UserAgent)
    | User Token (Maybe Lang) (Maybe UserAgent)


type alias Token =
    { sub : String
    , name : String
    , iat : Int
    }


type alias UserAgent =
    String


type Lang
    = English
    | SimplifiedChinese


{-| We parse `HTTP.Header` into `Result x Context` (e.g. Authorization jwt string into `User` values),
this is the "middleware" section of common web frameworks

Here, we attempt to decode JWT from `Authorization` header, then fallback to `Cookie`, then attempt
to extract accept-language and user-agent. If that succeed, our `Context is`User`otherwise, our`Context\` is Anonymous

-}
decodeContext : Json.Decode.Decoder Context
decodeContext =
    oneOf
        [ -- try to decode as User carrying JWT
          Json.Decode.map3 User
            (oneOf
                [ Json.Decode.field "authorization" authorizationDecoder
                , Json.Decode.field "cookie" authorizationDecoder
                ]
            )
            (Json.Decode.maybe (Json.Decode.field "accept-language" decodeLang))
            (Json.Decode.maybe (Json.Decode.field "user-agent" Json.Decode.string))
        , -- otherwise, settle for Anonymous user
          Json.Decode.map2 Anonymous
            (Json.Decode.maybe (Json.Decode.field "accept-language" decodeLang))
            (Json.Decode.maybe (Json.Decode.field "user-agent" Json.Decode.string))
        ]


decodeLang : Json.Decode.Decoder Lang
decodeLang =
    Json.Decode.string
        |> Json.Decode.andThen
            (\s ->
                if String.startsWith "zh-CN" s then
                    Json.Decode.succeed SimplifiedChinese

                else
                    Json.Decode.succeed English
            )


jwtDecoder : Json.Decode.Decoder Token
jwtDecoder =
    Json.Decode.map3 Token
        (Json.Decode.field "sub" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "iat" Json.Decode.int)


authorizationDecoder : Json.Decode.Decoder Token
authorizationDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (Jwt.decodeToken jwtDecoder
                >> Result.mapError jwtErrorToString
                >> decoderFromResult
            )


decoderFromResult : Result String a -> Json.Decode.Decoder a
decoderFromResult result =
    case result of
        Ok a ->
            Json.Decode.succeed a

        Err err ->
            Json.Decode.fail err


jwtErrorToString : Jwt.JwtError -> String
jwtErrorToString err =
    case err of
        Jwt.Unauthorized ->
            "Unauthorized"

        Jwt.TokenExpired ->
            "TokenExpired"

        Jwt.TokenNotExpired ->
            "TokenNotExpired"

        Jwt.TokenProcessingError s ->
            "Invalid token: " ++ s

        Jwt.TokenDecodeError jerr ->
            "Invalid token: " ++ Json.Decode.errorToString jerr


fromRequest : Request -> ( Method, Result Json.Decode.Error Context, Page )
fromRequest =
    Server.HTTP.parseRoute decodeContext (Server.HTTP.parsePage router NotFound)
