port module Main exposing (..)

import Html exposing (Html, div)
import Window
import Color
import Html.Attributes exposing (width, height, style)
import Html.Events exposing (onClick)
import Svg exposing (svg, use)
import Svg.Attributes exposing (xlinkHref, viewBox)
import Math.Vector3 as Vector3 exposing (Vec3, vec3)
import Math.Vector4 as Vector4 exposing (Vec4, vec4)
import WebGL
import Json.Encode as JE
import Json.Decode as JD
import WebGL.Settings.Blend
import Math.Matrix4 as Matrix4
import Gameroom exposing (programAt, Ports, Model, Msg)
import Gameroom.Utilities exposing (generatorFromList)


type alias Problem =
    Int


type alias Guess =
    Bool


port outgoing : String -> Cmd msg


port incoming : (String -> msg) -> Sub msg


ports : Ports (Msg Problem Guess)
ports =
    { outgoing = outgoing
    , incoming = incoming
    }


type alias Vertex =
    { position : Vec3, color : Vec4 }


main : Program Never (Model Problem Guess) (Msg Problem Guess)
main =
    programAt "spacecraterball"
        { copy =
            { name = "Spacecraterball"
            , instructions = "Will it go in?"
            , subheading = "Let the game begin!"
            }
        , view =
            (\windowSize ticks _ problem ->
                div []
                    [ viewNav
                    , viewWebglContainer windowSize
                        [ WebGL.entityWith
                            [ WebGL.Settings.Blend.add WebGL.Settings.Blend.srcAlpha WebGL.Settings.Blend.oneMinusSrcAlpha
                            ]
                            vertexShader
                            fragmentShader
                            (terrain ++ (ball problem ticks) |> WebGL.triangles)
                            { perspective = perspective ticks }
                        ]
                    ]
            )
        , isGuessCorrect =
            (\problem guess ->
                if problem == 0 then
                    guess
                else
                    not guess
            )
        , problemDecoder = JD.int
        , problemEncoder = JE.int
        , guessDecoder = JD.bool
        , guessEncoder = JE.bool
        , problemGenerator = generatorFromList -3 [ -2, -1, 0, 1, 2, 3 ]
        }
        ports


perspective : Int -> Matrix4.Mat4
perspective ticks =
    let
        theta =
            (ticks |> toFloat) / 200

        phi =
            pi / 6

        eye =
            vec3
                (sin theta * cos phi)
                (cos theta * cos phi)
                (sin phi)
                |> Vector3.scale 2
    in
        Matrix4.mul (Matrix4.makePerspective 45 1 0.01 100)
            (Matrix4.makeLookAt eye (vec3 0 0 0) (vec3 0 0 1))


viewWebglContainer : Window.Size -> List WebGL.Entity -> Html Bool
viewWebglContainer windowSize children =
    let
        minWH =
            min windowSize.width windowSize.height

        left =
            (max (windowSize.width - windowSize.height) 0) // 2

        top =
            (max (windowSize.height - windowSize.width) 0) // 2
    in
        WebGL.toHtml
            [ width minWH
            , height minWH
            , style
                [ ( "position", "absolute" )
                , ( "top", (toString top) ++ "px" )
                , ( "left", (toString left) ++ "px" )
                , ( "z-index", "9" )
                ]
            ]
            children


viewNav : Html Bool
viewNav =
    div
        [ style
            [ ( "position", "absolute" )
            , ( "bottom", "60px" )
            , ( "left", "50%" )
            , ( "transform", "translateX(-50%)" )
            , ( "z-index", "100" )
            , ( "cursor", "pointer" )
            ]
        ]
        [ viewButton True
        , viewButton False
        ]


viewButton : Bool -> Html Bool
viewButton guess =
    div
        [ style
            [ ( "display", "inline-block" )
            , ( "width", "60px" )
            , ( "height", "60px" )
            , ( "margin", "15px" )
            ]
        , onClick guess
        ]
        [ svg
            [ viewBox "0 0 200 200"
            , style
                [ ( "width", "100%" )
                , ( "height", "100%" )
                , ( "fill", "rgba(78,60,127,0.9)" )
                , ( "cursor", "pointer" )
                , ( "pointer-events", "none" )
                ]
            ]
            [ use
                [ xlinkHref
                    ("#spacecraterball-"
                        ++ (if guess then
                                "in"
                            else
                                "out"
                           )
                    )
                ]
                []
            ]
        ]


ball : Int -> Int -> List ( Vertex, Vertex, Vertex )
ball problem ticks =
    let
        ratio =
            if problem == 0 then
                min ((ticks |> toFloat) / 100) 1
            else
                (ticks |> toFloat) / 100

        isOver =
            ratio > 1

        offset =
            (toFloat problem) * 0.08
    in
        (viewBall 1.5
            (purple |> colorToVec4)
            (Matrix4.mul
                (Matrix4.makeTranslate
                    (vec3
                        ((0 + offset) - (0.8 + offset) * (1 - ratio))
                        0
                        (0.2 * (cos (ratio * pi - pi / 2) |> abs))
                    )
                )
                (Matrix4.makeRotate
                    ((ticks |> toFloat) / 10)
                    (vec3 0.2 0.4 0.8)
                )
            )
        )



-- Ball


type alias Shape =
    { nodes : List ( Float, Float, Float )
    , faces : List ( Int, Int, Int )
    }


getNode : Int -> Shape -> ( Float, Float, Float )
getNode i { nodes } =
    nodes |> List.drop i |> List.head |> Maybe.withDefault ( 0, 0, 0 )


ballShape : Shape
ballShape =
    { nodes =
        [ ( -0.767, 7.703, 4.056 )
        , ( 6.558, -1.018, 2.76 )
        , ( -2.475, -6.075, 2.169 )
        , ( -5.315, -4.073, -0.228 )
        , ( -5.672, 3.194, -2.916 )
        , ( 3.878, 4.616, -2.916 )
        , ( 1.59, -5.296, -2.916 )
        ]
    , faces =
        [ ( 0, 1, 2 )
        , ( 0, 2, 3 )
        , ( 0, 3, 4 )
        , ( 0, 4, 5 )
        , ( 0, 5, 1 )
        , ( 6, 1, 5 )
        , ( 6, 2, 1 )
        , ( 6, 3, 2 )
        , ( 6, 4, 3 )
        , ( 6, 5, 4 )
        ]
    }


viewBall : Float -> Vec4 -> Matrix4.Mat4 -> List ( Vertex, Vertex, Vertex )
viewBall scaleFactor color_ transform =
    let
        transformPoint =
            (\transform pt ->
                pt
                    |> Vector3.scale (0.005 * scaleFactor)
                    |> Matrix4.transform transform
            )

        ptIndexToVertex =
            (flip getNode <| ballShape) >> ((\( x, y, z ) -> vec3 x y z)) >> (transformPoint transform) >> (flip Vertex <| color_)
    in
        List.map
            (\( pointIndex1, pointIndex2, pointIndex3 ) ->
                ( ptIndexToVertex pointIndex1
                , ptIndexToVertex pointIndex2
                , ptIndexToVertex pointIndex3
                )
            )
            ballShape.faces



-- Terrain


terrainUnitSize : Int
terrainUnitSize =
    51


light : Vec3
light =
    vec3 -0.3 0.2 1 |> Vector3.normalize


terrainWaveHeight : Float -> Float -> Float
terrainWaveHeight x y =
    List.foldl
        (\i acc ->
            let
                h =
                    (x + y * 0.6 + i * 0.3)
                        |> (*) (3 * i)
                        |> sin
                        |> (*) (0.2 - 0.04 * i)
                        |> (+) acc
            in
                h * 0.3
        )
        0
        [ 1, 2, 3 ]


terrainPoint : Int -> Int -> Int -> Vec3
terrainPoint n i j =
    let
        d =
            1.0 / ((n - 1) |> toFloat)

        x =
            (toFloat i) * d - 0.5

        y =
            (toFloat j) * d - 0.5

        z =
            terrainWaveHeight x y
    in
        vec3 x y z


colorToVec4 : Color.Color -> Vec4
colorToVec4 color_ =
    color_
        |> Color.toRgb
        |> (\{ red, green, blue, alpha } ->
                vec4
                    ((toFloat red) / 255)
                    ((toFloat green) / 255)
                    ((toFloat blue) / 255)
                    alpha
           )


cyan : Color.Color
cyan =
    Color.rgb 39 171 178


purple : Color.Color
purple =
    Color.rgb 78 60 127


brighten : Float -> Color.Color -> Color.Color
brighten fact =
    Color.toHsl
        >> (\{ hue, saturation, lightness } -> Color.hsl hue saturation (lightness * fact))


terrainSquare : Int -> Int -> Int -> List ( Vertex, Vertex, Vertex )
terrainSquare n i j =
    let
        d =
            1.0 / ((n - 1) |> toFloat)

        fac =
            (toFloat (i + j)) * d / 2

        pt11 =
            terrainPoint n i j

        pt12 =
            terrainPoint n (i + 1) j

        pt13 =
            terrainPoint n (i + 1) (j + 1)

        op1 =
            Vector3.cross (Vector3.sub pt11 pt12) (Vector3.sub pt11 pt13)
                |> Vector3.normalize
                |> Vector3.dot light

        color1 =
            cyan |> brighten op1 |> colorToVec4

        pt21 =
            terrainPoint n i j

        pt22 =
            terrainPoint n (i + 1) (j + 1)

        pt23 =
            terrainPoint n i (j + 1)

        op2 =
            Vector3.cross (Vector3.sub pt21 pt22) (Vector3.sub pt21 pt23)
                |> Vector3.normalize
                |> Vector3.dot light

        color2 =
            cyan |> brighten op2 |> colorToVec4
    in
        [ ( Vertex pt11 color1
          , Vertex pt12 color1
          , Vertex pt13 color1
          )
        , ( Vertex pt21 color2
          , Vertex pt22 color2
          , Vertex pt23 color2
          )
        ]


terrain : List ( Vertex, Vertex, Vertex )
terrain =
    List.repeat terrainUnitSize 0
        |> List.indexedMap
            (\i _ ->
                List.repeat terrainUnitSize 0
                    |> List.indexedMap
                        (\j _ ->
                            let
                                distance =
                                    ((i - terrainUnitSize // 2) ^ 2 + (j - terrainUnitSize // 2) ^ 2 |> toFloat) ^ 0.5
                            in
                                ( terrainSquare terrainUnitSize i j
                                , (distance > (terrainUnitSize // 12 |> toFloat))
                                )
                        )
                    |> List.filter (\( geo, isIncluded ) -> isIncluded)
                    |> List.map (\( geo, isIncluded ) -> geo)
                    |> List.concat
            )
        |> List.concat



-- Shaders


vertexShader : WebGL.Shader { attr | position : Vec3, color : Vec4 } { unif | perspective : Matrix4.Mat4 } { vcolor : Vec4 }
vertexShader =
    [glsl|
attribute vec3 position;
attribute vec4 color;
uniform mat4 perspective;
varying vec4 vcolor;
void main () {
    gl_Position = perspective * vec4(position, 1.0);
    vcolor = color;
}
|]


fragmentShader : WebGL.Shader {} u { vcolor : Vec4 }
fragmentShader =
    [glsl|
precision mediump float;
varying vec4 vcolor;
void main () {
    gl_FragColor = vcolor;
}
|]
