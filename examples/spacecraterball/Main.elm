port module Main exposing (..)

import Html exposing (Html, div)
import Time
import Window
import Color
import Random
import Html.Attributes exposing (width, height, style)
import Html.Events exposing (onClick)
import Svg exposing (svg, use)
import Svg.Attributes exposing (xlinkHref, viewBox)
import Math.Vector3 as Vector3 exposing (Vec3, vec3)
import Math.Vector4 as Vector4 exposing (Vec4, vec4)
import WebGL
import WebGL.Settings.Blend as Blend
import Json.Encode as JE
import Json.Decode as JD
import Math.Matrix4 as Matrix4
import Gameroom exposing (..)


type alias Problem =
    { incomingAngle : Float
    , deviationFromCorrectPath : Float
    }


problemDecoder : JD.Decoder Problem
problemDecoder =
    JD.map2 Problem
        (JD.field "incomingAngle" JD.float)
        (JD.field "deviationFromCorrectPath" JD.float)


problemEncoder : Problem -> JE.Value
problemEncoder record =
    JE.object
        [ ( "incomingAngle", JE.float <| record.incomingAngle )
        , ( "deviationFromCorrectPath", JE.float <| record.deviationFromCorrectPath )
        ]


problemGenerator : Random.Generator Problem
problemGenerator =
    Random.map2 Problem (Random.float 0 (2 * pi)) (Random.float -0.3 0.3)


willStayInCrater : Problem -> Bool
willStayInCrater problem =
    abs problem.deviationFromCorrectPath < 0.1


type alias Guess =
    Bool


port outgoing : JE.Value -> Cmd msg


port incoming : (JE.Value -> msg) -> Sub msg


ports : Ports (Msg Problem Guess)
ports =
    { outgoing = outgoing
    , incoming = incoming
    }


type alias Vertex =
    { position : Vec3
    , normal : Vec3
    , color : Vec4
    }


main : Program Never (Model Problem Guess) (Msg Problem Guess)
main =
    programWith
        [ baseUrl "spacecraterball"
        , icon "🚀"
        , name "Spacecraterball"
        , subheading "A futuristic physics game"
        , instructions "Will the rock land inside the crater or bounce off?"
        ]
        { view =
            (\context problem ->
                div []
                    [ viewNav context.ownGuess
                    , viewWebglContainer context.windowSize
                        [ WebGL.entityWith
                            [ Blend.add Blend.srcAlpha Blend.oneMinusSrcAlpha ]
                            terrainVertexShader
                            fragmentShader
                            terrain
                            { perspective = perspective context.roundTime
                            , transform = Matrix4.identity
                            }
                        , WebGL.entityWith
                            [ Blend.add Blend.srcAlpha Blend.oneMinusSrcAlpha ]
                            ballVertexShader
                            fragmentShader
                            ballMesh
                            { perspective = perspective context.roundTime
                            , transform = ballTransform problem context.roundTime
                            }
                        ]
                    ]
            )
        , isGuessCorrect =
            (\problem guess ->
                if willStayInCrater problem then
                    guess
                else
                    not guess
            )
        , problemDecoder = problemDecoder
        , problemEncoder = problemEncoder
        , guessDecoder = JD.bool
        , guessEncoder = JE.bool
        , problemGenerator = problemGenerator
        }
        ports



-- Views


perspective : Time.Time -> Matrix4.Mat4
perspective time =
    let
        theta =
            time / 6400

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


viewNav : Maybe Guess -> Html Bool
viewNav ownGuess =
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
        [ viewButton { isHighlighted = (ownGuess == Just True), guess = True }
        , viewButton { isHighlighted = (ownGuess == Just False), guess = False }
        ]


viewButton : { isHighlighted : Bool, guess : Bool } -> Html Bool
viewButton { isHighlighted, guess } =
    div
        [ style <|
            [ ( "display", "inline-block" )
            , ( "width", "60px" )
            , ( "height", "60px" )
            , ( "margin", "15px" )
            , ( "padding", "1px" )
            , ( "border-radius", "50%" )
            , ( "border"
              , "2px solid "
                    ++ (if isHighlighted then
                            "rgb(78, 60, 127)"
                        else
                            "transparent"
                       )
              )
            ]
        , onClick guess
        ]
        [ svg
            [ viewBox "0 0 200 200"
            , style
                [ ( "width", "100%" )
                , ( "height", "100%" )
                , ( "fill", "rgb(78, 60, 127)" )
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



-- Colors


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



-- Ball


type alias Shape =
    { nodes : List ( Float, Float, Float )
    , faces : List ( Int, Int, Int )
    }


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


getNode : Int -> Shape -> Vec3
getNode i { nodes } =
    nodes
        |> List.drop i
        |> List.head
        |> Maybe.withDefault ( 0, 0, 0 )
        |> (\( x, y, z ) -> vec3 x y z)


ballMesh : WebGL.Mesh Vertex
ballMesh =
    ballShape.faces
        |> List.map
            (\( ptIndex1, ptIndex2, ptIndex3 ) ->
                let
                    color_ =
                        colorToVec4 purple

                    pt1 =
                        getNode ptIndex1 ballShape
                            |> Vector3.scale 0.0075

                    pt2 =
                        getNode ptIndex2 ballShape
                            |> Vector3.scale 0.0075

                    pt3 =
                        getNode ptIndex3 ballShape
                            |> Vector3.scale 0.0075

                    normal =
                        Vector3.cross (Vector3.sub pt2 pt1) (Vector3.sub pt3 pt1)
                            |> Vector3.normalize
                in
                    ( Vertex pt1 normal color_
                    , Vertex pt2 normal color_
                    , Vertex pt3 normal color_
                    )
                        |> Debug.log "bal"
            )
        |> WebGL.triangles


ballTransform : Problem -> Time.Time -> Matrix4.Mat4
ballTransform problem time =
    let
        ratio =
            if willStayInCrater problem then
                min (time / 3200) 1
            else
                time / 3200

        isOver =
            ratio > 1

        offset =
            problem.deviationFromCorrectPath

        xy =
            (0 + offset) - (0.8 + offset) * (1 - ratio)

        translate =
            Matrix4.makeTranslate
                (vec3
                    (xy * (cos problem.incomingAngle))
                    (xy * (sin problem.incomingAngle))
                    (0.2 * (cos (ratio * pi - pi / 2) |> abs) + 0.05)
                )

        rotate =
            Matrix4.makeRotate
                (time / 320)
                (vec3 0.2 0.4 0.8)
    in
        List.foldr (\current accumulator -> Matrix4.mul current accumulator)
            Matrix4.identity
            [ translate
            , rotate
            ]



-- Terrain


terrainUnitSize : Int
terrainUnitSize =
    11


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
            1.0 / (n |> toFloat)

        x =
            (toFloat i) * d - 0.5

        y =
            (toFloat j) * d - 0.5

        z =
            terrainWaveHeight x y
    in
        vec3 x y z


terrainSquare : Int -> Int -> Int -> List ( Vertex, Vertex, Vertex )
terrainSquare n i j =
    let
        pt11 =
            terrainPoint n i j

        pt12 =
            terrainPoint n (i + 1) j

        pt13 =
            terrainPoint n (i + 1) (j + 1)

        normal1 =
            Vector3.cross (Vector3.sub pt12 pt11) (Vector3.sub pt13 pt11)
                |> Vector3.normalize

        pt21 =
            terrainPoint n i j

        pt22 =
            terrainPoint n (i + 1) (j + 1)

        pt23 =
            terrainPoint n i (j + 1)

        normal2 =
            Vector3.cross (Vector3.sub pt22 pt21) (Vector3.sub pt23 pt21)
                |> Vector3.normalize

        color_ =
            cyan
                |> colorToVec4
    in
        [ ( Vertex pt11 normal1 color_
          , Vertex pt12 normal1 color_
          , Vertex pt13 normal1 color_
          )
        , ( Vertex pt21 normal2 color_
          , Vertex pt22 normal2 color_
          , Vertex pt23 normal2 color_
          )
        ]


terrain : WebGL.Mesh Vertex
terrain =
    List.repeat terrainUnitSize 0
        |> List.indexedMap
            (\i _ ->
                List.repeat terrainUnitSize 0
                    |> List.indexedMap (\j _ -> terrainSquare terrainUnitSize i j)
                    |> List.concat
            )
        |> List.concat
        |> WebGL.triangles



-- Shaders


type alias Uniforms =
    { perspective : Matrix4.Mat4
    , transform : Matrix4.Mat4
    }


type alias Varyings =
    { vColor : Vec4
    }


terrainVertexShader : WebGL.Shader Vertex Uniforms Varyings
terrainVertexShader =
    [glsl|
attribute vec3 position;
attribute vec3 normal;
attribute vec4 color;
uniform mat4 perspective;
uniform mat4 transform;
varying vec4 vColor;
void main () {
    gl_Position = (perspective * transform) * vec4(position, 1.0);
    float brightness = 1.0 - (1.0 - dot(normalize(vec3(0.3, -0.2, 1)), normal)) * 1.2;
    float opacityFactor;
    float d = pow(pow(position.x, 2.0) + pow(position.y, 2.0), 0.5);
    const float dMin = 0.05;
    const float dMax = 0.08;
    if (d < dMin) {
      opacityFactor = 0.0;
    } else if (d < dMax) {
      opacityFactor = 1.0 * (d - dMin) / (dMax - dMin);
    } else {
      opacityFactor = 1.0;
    }
    vColor = vec4(
      color.r * brightness,
      color.g * brightness,
      color.b * brightness,
      color.a * opacityFactor
    );
}
|]


ballVertexShader : WebGL.Shader Vertex Uniforms Varyings
ballVertexShader =
    [glsl|
attribute vec3 position;
attribute vec3 normal;
attribute vec4 color;
uniform mat4 perspective;
uniform mat4 transform;
varying vec4 vColor;
void main () {
    vec4 transformedNormal = transform * vec4(normal, 1.0);
    gl_Position = (perspective * transform) * vec4(position, 1.0);
    float brightness = 1.0 + (1.0 - dot(
      normalize(vec3(0.3, -0.2, 1)),
      normalize(vec3(transformedNormal))
    )) * 0.8;
    vColor = vec4(
      color.r * brightness,
      color.g * brightness,
      color.b * brightness,
      color.a
    );
}
|]


fragmentShader : WebGL.Shader {} Uniforms Varyings
fragmentShader =
    [glsl|
precision mediump float;
varying vec4 vColor;
void main () {
    gl_FragColor = vColor;
}
|]
