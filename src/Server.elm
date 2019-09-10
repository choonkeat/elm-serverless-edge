module Server exposing (Flags, Model, Msg(..), init, main, subscriptions, update)

{-| Example server side code
-}

import Html.Attributes exposing (lang)
import Http
import Json.Decode
import Json.Encode
import Route
import Server.HTTP exposing (Body, Headers, Method(..), Request, StatusCode(..))
import Server.KV
import Server.Platform
import Task


main =
    Server.Platform.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


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
            ( model
            , Server.Platform.writeResponse statuscode body headers request
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
    case Route.fromRequest request of
        ( method, ctx, Route.CounterPage ) ->
            -- we load the counter from key-value store if possible
            -- increment, save it back to key-value store
            -- render that counter along with our in-memory model counter
            let
                newModel =
                    { model | counter = model.counter + 1 }

                readMaybeIntTask =
                    Server.KV.read model.tableName rowKey (Json.Decode.maybe Json.Decode.int)

                writeIncrementTask maybeInt =
                    Server.KV.write
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
            ( model, Server.Platform.writeResponse StatusNotFound "Page not found!" Json.Encode.null request )


subscriptions : Model -> Sub Msg
subscriptions model =
    -- you MUST use `Server.Platform.writeResponse` somewhere
    -- otherwise your server won't boot: missing `app.ports.responseWrite`
    -- (even if it booted, your HTTP request will hang since it's left unreplied)
    Server.Platform.handleRequest OnHttpRequest



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
