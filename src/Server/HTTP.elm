module Server.HTTP exposing
    ( Body
    , Headers
    , Method(..)
    , Request
    , StatusCode(..)
    , Url
    , bodyOf
    , headersOf
    , methodFromString
    , methodOf
    , parsePage
    , parseRoute
    , requestFrom
    , statusInt
    , urlOf
    )

{-| Data types and their helper functions to work with HTTP handlers
-}

import Json.Decode
import Json.Encode
import Url
import Url.Parser


{-| Given

1.  json decoder for HTTP headers
2.  url parser

this function will return a triplet of

( http method
, a value decoded from header
, a page parsed from url
)

-}
parseRoute : Json.Decode.Decoder a -> (String -> b) -> Request -> ( Method, Result Json.Decode.Error a, b )
parseRoute decodeHeader parseUrl req =
    let
        httpMethod =
            methodOf req

        context =
            Json.Decode.decodeValue decodeHeader (headersOf req)

        page =
            parseUrl (urlOf req)
    in
    ( httpMethod, context, page )


parsePage : Url.Parser.Parser (a -> a) a -> a -> String -> a
parsePage router defaultPage urlString =
    case Url.fromString urlString of
        Nothing ->
            defaultPage

        Just s ->
            Maybe.withDefault defaultPage (Url.Parser.parse router s)


type alias Url =
    String


type alias Body =
    String


type Method
    = GET
    | HEAD
    | POST
    | PUT
    | DELETE
    | CONNECT
    | OPTIONS
    | TRACE
    | PATCH


methodString : Method -> String
methodString method =
    case method of
        GET ->
            "GET"

        HEAD ->
            "HEAD"

        POST ->
            "POST"

        PUT ->
            "PUT"

        DELETE ->
            "DELETE"

        CONNECT ->
            "CONNECT"

        OPTIONS ->
            "OPTIONS"

        TRACE ->
            "TRACE"

        PATCH ->
            "PATCH"


methodFromString : String -> Method
methodFromString str =
    case str of
        "GET" ->
            GET

        "HEAD" ->
            HEAD

        "POST" ->
            POST

        "PUT" ->
            PUT

        "DELETE" ->
            DELETE

        "CONNECT" ->
            CONNECT

        "OPTIONS" ->
            OPTIONS

        "TRACE" ->
            TRACE

        "PATCH" ->
            PATCH

        _ ->
            GET


type alias Request =
    Json.Decode.Value


type alias Headers =
    Json.Decode.Value


responseKey =
    "response"


methodKey =
    "method"


urlKey =
    "url"


bodyKey =
    "body"


headersKey =
    "headers"


requestFrom : { response : Json.Decode.Value, method : Method, url : Url, body : Body, headers : Headers } -> Request
requestFrom record =
    Json.Encode.object
        [ ( responseKey, record.response )
        , ( methodKey, Json.Encode.string (methodString record.method) )
        , ( urlKey, Json.Encode.string record.url )
        , ( bodyKey, Json.Encode.string record.body )
        , ( headersKey, record.headers )
        ]


methodOf : Request -> Method
methodOf request =
    Json.Decode.decodeValue (Json.Decode.field methodKey Json.Decode.string) request
        |> Result.map methodFromString
        |> Result.toMaybe
        |> Maybe.withDefault GET


urlOf : Request -> String
urlOf request =
    Json.Decode.decodeValue (Json.Decode.field urlKey Json.Decode.string) request
        |> Result.toMaybe
        |> Maybe.withDefault ""


bodyOf : Request -> String
bodyOf request =
    Json.Decode.decodeValue (Json.Decode.field bodyKey Json.Decode.string) request
        |> Result.toMaybe
        |> Maybe.withDefault ""


headersOf : Request -> Headers
headersOf request =
    Json.Decode.decodeValue (Json.Decode.field headersKey Json.Decode.value) request
        |> Result.toMaybe
        |> Maybe.withDefault Json.Encode.null



-- curl https://www.iana.org/assignments/http-status-codes/http-status-codes.txt | grep '     [0-9]\S\S ' | egrep -vi 'unused|unassigned' | sed 's/\[.*//g' | while read code words; do word=`echo Status$words | sed 's/[ -]//g'`; echo "$word -> $code"; done


type StatusCode
    = StatusContinue
    | StatusSwitchingProtocols
    | StatusProcessing
    | StatusEarlyHints
    | StatusOK
    | StatusCreated
    | StatusAccepted
    | StatusNonAuthoritativeInformation
    | StatusNoContent
    | StatusResetContent
    | StatusPartialContent
    | StatusMultiStatus
    | StatusAlreadyReported
    | StatusIMUsed
    | StatusMultipleChoices
    | StatusMovedPermanently
    | StatusFound
    | StatusSeeOther
    | StatusNotModified
    | StatusUseProxy
    | StatusTemporaryRedirect
    | StatusPermanentRedirect
    | StatusBadRequest
    | StatusUnauthorized
    | StatusPaymentRequired
    | StatusForbidden
    | StatusNotFound
    | StatusMethodNotAllowed
    | StatusNotAcceptable
    | StatusProxyAuthenticationRequired
    | StatusRequestTimeout
    | StatusConflict
    | StatusGone
    | StatusLengthRequired
    | StatusPreconditionFailed
    | StatusPayloadTooLarge
    | StatusURITooLong
    | StatusUnsupportedMediaType
    | StatusRangeNotSatisfiable
    | StatusExpectationFailed
    | StatusMisdirectedRequest
    | StatusUnprocessableEntity
    | StatusLocked
    | StatusFailedDependency
    | StatusTooEarly
    | StatusUpgradeRequired
    | StatusPreconditionRequired
    | StatusTooManyRequests
    | StatusRequestHeaderFieldsTooLarge
    | StatusUnavailableForLegalReasons
    | StatusInternalServerError
    | StatusNotImplemented
    | StatusBadGateway
    | StatusServiceUnavailable
    | StatusGatewayTimeout
    | StatusHTTPVersionNotSupported
    | StatusVariantAlsoNegotiates
    | StatusInsufficientStorage
    | StatusLoopDetected
    | StatusNotExtended
    | StatusNetworkAuthenticationRequired


statusInt : StatusCode -> Int
statusInt code =
    case code of
        StatusContinue ->
            100

        StatusSwitchingProtocols ->
            101

        StatusProcessing ->
            102

        StatusEarlyHints ->
            103

        StatusOK ->
            200

        StatusCreated ->
            201

        StatusAccepted ->
            202

        StatusNonAuthoritativeInformation ->
            203

        StatusNoContent ->
            204

        StatusResetContent ->
            205

        StatusPartialContent ->
            206

        StatusMultiStatus ->
            207

        StatusAlreadyReported ->
            208

        StatusIMUsed ->
            226

        StatusMultipleChoices ->
            300

        StatusMovedPermanently ->
            301

        StatusFound ->
            302

        StatusSeeOther ->
            303

        StatusNotModified ->
            304

        StatusUseProxy ->
            305

        StatusTemporaryRedirect ->
            307

        StatusPermanentRedirect ->
            308

        StatusBadRequest ->
            400

        StatusUnauthorized ->
            401

        StatusPaymentRequired ->
            402

        StatusForbidden ->
            403

        StatusNotFound ->
            404

        StatusMethodNotAllowed ->
            405

        StatusNotAcceptable ->
            406

        StatusProxyAuthenticationRequired ->
            407

        StatusRequestTimeout ->
            408

        StatusConflict ->
            409

        StatusGone ->
            410

        StatusLengthRequired ->
            411

        StatusPreconditionFailed ->
            412

        StatusPayloadTooLarge ->
            413

        StatusURITooLong ->
            414

        StatusUnsupportedMediaType ->
            415

        StatusRangeNotSatisfiable ->
            416

        StatusExpectationFailed ->
            417

        StatusMisdirectedRequest ->
            421

        StatusUnprocessableEntity ->
            422

        StatusLocked ->
            423

        StatusFailedDependency ->
            424

        StatusTooEarly ->
            425

        StatusUpgradeRequired ->
            426

        StatusPreconditionRequired ->
            428

        StatusTooManyRequests ->
            429

        StatusRequestHeaderFieldsTooLarge ->
            431

        StatusUnavailableForLegalReasons ->
            451

        StatusInternalServerError ->
            500

        StatusNotImplemented ->
            501

        StatusBadGateway ->
            502

        StatusServiceUnavailable ->
            503

        StatusGatewayTimeout ->
            504

        StatusHTTPVersionNotSupported ->
            505

        StatusVariantAlsoNegotiates ->
            506

        StatusInsufficientStorage ->
            507

        StatusLoopDetected ->
            508

        StatusNotExtended ->
            510

        StatusNetworkAuthenticationRequired ->
            511
