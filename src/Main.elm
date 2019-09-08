module Main exposing (..)

import Http exposing (request)
import Json.Decode
import Json.Encode
import Process
import Route
import Server.DB
import Server.HTTP exposing (Body, Headers, Request, StatusCode(..))
import Server.Handler
import Task
import Time
import Url.Parser


type alias Flags =
    { tableName : String
    }


type alias Model =
    { counter : Int
    , tableName : String
    }


type Msg
    = OnHttpRequest Request
    | HTTPRespond StatusCode Body Headers Request


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { counter = 0, tableName = flags.tableName }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnHttpRequest request ->
            -- carve out `OnHttpRequest` to handle separately from other Msg
            routeRequest request model

        HTTPRespond statuscode body headers request ->
            -- usually our server side activities end with a chain of Task
            -- to end our http handling with a Cmd, the simplest would be to
            -- construct a msg that will always writeResponse
            ( model
            , Server.Handler.writeResponse statuscode body headers request
            )


routeRequest : Request -> Model -> ( Model, Cmd Msg )
routeRequest request model =
    let
        rowKey =
            "key123"

        headers =
            Json.Encode.object
                [ ( "counter", Json.Encode.int model.counter )
                , ( "tableName", Json.Encode.string model.tableName )
                ]
    in
    case Debug.log "http" (Route.fromRequest request) of
        ( method, ctx, Route.Homepage ) ->
            -- we load the counter from key-value store if possible
            -- increment, save it back to key-value store
            -- render that counter along with our in-memory model counter
            let
                newModel =
                    { model | counter = model.counter + 1 }

                readMaybeIntTask =
                    Server.DB.read model.tableName rowKey (Json.Decode.maybe Json.Decode.int)

                writeIncrementTask maybeInt =
                    Server.DB.write
                        model.tableName
                        rowKey
                        (Json.Encode.int (Maybe.withDefault 0 maybeInt + 1))

                msgFromResult result =
                    case result of
                        Ok maybeInt ->
                            HTTPRespond StatusOK (Debug.toString { state = newModel.counter, dbvalue = maybeInt }) headers request

                        Err err ->
                            HTTPRespond StatusInternalServerError (stringFromHttpError err) headers request
            in
            ( newModel
            , readMaybeIntTask
                |> Task.andThen writeIncrementTask
                |> Task.attempt msgFromResult
            )

        ( _, _, _ ) ->
            ( model, Server.Handler.writeResponse StatusNotFound "Page not found!" Json.Encode.null request )


subscriptions : Model -> Sub Msg
subscriptions model =
    Server.Handler.handleRequest OnHttpRequest



-- HELPERS


stringFromHttpError : Http.Error -> String
stringFromHttpError err =
    case err of
        Http.BadUrl s ->
            "Bad url: " ++ s

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "NetworkError"

        Http.BadStatus int ->
            "Unexpected response status: " ++ String.fromInt int

        Http.BadBody s ->
            "Unexpected response body: " ++ s
