module Main exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (width, height)
import Math.Vector3 as Vector3 exposing (Vec3, vec3)
import Math.Vector4 as Vector4 exposing (Vec4, vec4)
import WebGL
import WebGL.Settings.Blend
import Math.Matrix4 as Matrix4


type alias Vertex =
    { position : Vec3, color : Vec4 }


main : Html msg
main =
    view 2


mesh : Int -> WebGL.Mesh Vertex
mesh tick =
    terrain
        |> WebGL.triangles


view : Int -> Html msg
view ticks =
    let
        theta =
            pi / 2

        phi =
            pi / 4

        eye =
            vec3
                (sin theta * cos phi)
                (cos theta * cos phi)
                (sin phi)
                |> Vector3.scale 2
                |> Debug.log ""

        minWH =
            300
    in
        WebGL.toHtml
            [ width minWH, height minWH ]
            [ WebGL.entityWith
                [ WebGL.Settings.Blend.add WebGL.Settings.Blend.srcAlpha WebGL.Settings.Blend.oneMinusSrcAlpha
                ]
                vertexShader
                fragmentShader
                (mesh ticks)
                { perspective = perspective eye }
            ]


perspective : Vec3 -> Matrix4.Mat4
perspective eye =
    Matrix4.mul (Matrix4.makePerspective 45 1 0.01 100)
        (Matrix4.makeLookAt eye (vec3 0 0 0) (vec3 0 0 1))



-- Terrain


terrainUnitSize : Int
terrainUnitSize =
    29


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

        color_ =
            vec4 1 1 1 fac

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
                |> (*) 0.8

        color1 =
            vec4 1 0 0 op1

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
                |> (*) 0.8

        color2 =
            vec4 1 0 0 op2
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
                    |> List.indexedMap (\j _ -> terrainSquare terrainUnitSize i j)
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
