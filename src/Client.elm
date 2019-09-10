module Client exposing (main)

import Html exposing (a, text)
import Html.Attributes exposing (href)


main =
    a [ href "/api/counter" ] [ text "This page has moved." ]
