port module Main exposing (..)

import Html.Attributes exposing (width, height, style)
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
    String


type alias Guess =
    String


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
            (\windowSize ticks _ _ _ ->
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
                            ]
                        ]
                        [ WebGL.entityWith
                            [ WebGL.Settings.Blend.add WebGL.Settings.Blend.srcAlpha WebGL.Settings.Blend.oneMinusSrcAlpha
                            ]
                            vertexShader
                            fragmentShader
                            (mesh ticks)
                            { perspective = perspective eye }
                        ]
            )
        , isGuessCorrect = (\problem guess -> guess == "Yes")
        , problemDecoder = JD.string
        , problemEncoder = JE.string
        , guessDecoder = JD.string
        , guessEncoder = JE.string
        , problemGenerator = generatorFromList "1" [ "2" ]
        }
        ports


mesh : Int -> WebGL.Mesh Vertex
mesh tick =
    (ball
        (Matrix4.mul
            (Matrix4.makeTranslate
                (vec3
                    (0)
                    (0)
                    (-0.5)
                )
            )
            (Matrix4.makeRotate
                ((tick |> toFloat) / 10)
                (vec3 0.2 0.4 0.8)
            )
        )
    )
        |> (++)
            terrain
        |> WebGL.triangles


perspective : Vec3 -> Matrix4.Mat4
perspective eye =
    Matrix4.mul (Matrix4.makePerspective 45 1 0.01 100)
        (Matrix4.makeLookAt eye (vec3 0 0 0) (vec3 0 0 1))



-- Ball


ball : Matrix4.Mat4 -> List ( Vertex, Vertex, Vertex )
ball transform =
    let
        pt1 =
            vec3 -0.767 7.703 4.056

        pt2 =
            vec3 6.558 -1.018 2.76

        pt3 =
            vec3 -2.475 -6.075 2.169

        pt4 =
            vec3 -5.315 -4.073 -0.228

        pt5 =
            vec3 -5.672 3.194 -2.916

        pt6 =
            vec3 3.878 4.616 -2.916

        pt7 =
            vec3 1.59 -5.296 -2.916

        transformPoint =
            (\transform pt ->
                pt
                    |> Vector3.scale 0.005
                    |> Matrix4.transform transform
                    |> Vector3.add (vec3 0 0 0.5)
            )

        ptToVertex =
            let
                color_ =
                    vec4 0.30588 0.235 0.498 1
            in
                (flip Vertex <| color_) << (transformPoint transform)
    in
        List.map
            (\( pt1, pt2, pt3 ) ->
                ( (ptToVertex pt1)
                , (ptToVertex pt2)
                , (ptToVertex pt3)
                )
            )
            [ ( pt1, pt2, pt3 )
            , ( pt1, pt3, pt4 )
            , ( pt1, pt4, pt5 )
            , ( pt1, pt5, pt6 )
            , ( pt1, pt2, pt3 )
            , ( pt1, pt6, pt2 )
            , ( pt7, pt2, pt6 )
            , ( pt7, pt3, pt2 )
            , ( pt7, pt4, pt3 )
            , ( pt7, pt5, pt4 )
            , ( pt7, pt6, pt5 )
            ]



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
                h * 0.4
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


terrainSquare : Int -> Int -> Int -> List ( Vertex, Vertex, Vertex )
terrainSquare n i j =
    let
        d =
            1.0 / ((n - 1) |> toFloat)

        fac =
            (toFloat (i + j)) * d / 2

        baseColor =
            vec4 (39 / 255 / 1.2) (171 / 255 / 1.2) (178 / 255 / 1.2)

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
            baseColor op1

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
            baseColor op2
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
                                , (distance > (terrainUnitSize // 8 |> toFloat))
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
