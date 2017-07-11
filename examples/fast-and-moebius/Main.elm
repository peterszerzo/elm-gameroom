port module Main exposing (..)

import Json.Encode as JE
import Json.Decode as JD
import Color
import Window
import Html exposing (Html, div)
import Html.Attributes exposing (width, height, style)
import Html.Events exposing (onClick)
import Math.Vector3 as Vector3 exposing (Vec3, vec3)
import Math.Vector4 as Vector4 exposing (Vec4, vec4)
import Math.Matrix4 as Matrix4
import WebGL
import Gameroom exposing (..)
import Gameroom.Utils exposing (generatorFromList)


type alias Problem =
    Int


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


type alias CarSpecs =
    { acceleration : Float
    , maxSpeed : Float
    }


type alias Car =
    { color : Color.Color
    , specs : CarSpecs
    , lateralPosition : Float
    }


cars : List Car
cars =
    [ { color = red
      , specs =
            { acceleration = 0.5
            , maxSpeed = 2
            }
      , lateralPosition = -1
      }
    , { color = lightGrey
      , specs =
            { acceleration = 0.375
            , maxSpeed = 3
            }
      , lateralPosition = -0.33
      }
    , { color = black
      , specs =
            { acceleration = 0.75
            , maxSpeed = 1.5
            }
      , lateralPosition = 0.33
      }
    , { color = purple
      , specs =
            { acceleration = 0.625
            , maxSpeed = 2.5
            }
      , lateralPosition = 1
      }
    ]


main : Program Never (Model Problem Guess) (Msg Problem Guess)
main =
    gameWith
        [ basePath "/fast-and-moebius"
        , icon "🏎️"
        , name "Fast and Moebius"
        , subheading "Engines and linear algebra! (dev in progress, not yet playable)"
        , instructions "Which car is the winner?"
        ]
        { view =
            (\context problem ->
                let
                    ticks =
                        context.roundTime / 16

                    perspective_ =
                        perspective ticks
                in
                    div []
                        [ viewNav context.ownGuess
                        , viewWebglContainer context.windowSize <|
                            [ WebGL.entity
                                vertexShader
                                fragmentShader
                                moebiusMesh
                                { perspective = perspective_
                                , transform = Matrix4.identity
                                }
                            ]
                                ++ (List.map
                                        (\car ->
                                            let
                                                t =
                                                    ticks / 100

                                                vMax =
                                                    car.specs.maxSpeed

                                                a =
                                                    car.specs.acceleration

                                                tMax =
                                                    vMax / a

                                                carAngle =
                                                    if (t < tMax) then
                                                        a * (t ^ 2) / 2
                                                    else
                                                        a * (tMax ^ 2) / 2 + vMax * (t - tMax)
                                            in
                                                WebGL.entity
                                                    vertexShader
                                                    fragmentShader
                                                    (carMesh car.color)
                                                    { perspective = perspective_
                                                    , transform = carTransform car.lateralPosition carAngle
                                                    }
                                        )
                                        cars
                                   )
                        ]
            )
        , evaluate =
            (\problem guess ->
                if (problem == 0) then
                    (if guess then
                        100
                     else
                        0
                    )
                else
                    (if guess then
                        0
                     else
                        100
                    )
            )
        , problemDecoder = JD.int
        , problemEncoder = JE.int
        , guessDecoder = JD.bool
        , guessEncoder = JE.bool
        , problemGenerator = generatorFromList -3 [ -2, -1, 0, 1, 2, 3 ]
        }
        ports



-- Views


perspective : Float -> Matrix4.Mat4
perspective time =
    let
        theta =
            (sin (time / 800)) * pi / 6

        phi =
            pi / 6

        eye =
            vec3
                (sin theta * cos phi)
                (cos theta * cos phi)
                (sin phi)
                |> Vector3.scale
                    (2.5
                        - ((time / 1200) |> clamp 0 0.8)
                    )
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
            , ( "bottom", "40px" )
            , ( "left", "50%" )
            , ( "transform", "translateX(-50%)" )
            , ( "z-index", "100" )
            , ( "cursor", "pointer" )
            ]
        ]
    <|
        List.map
            (\car ->
                viewButton car.color { isHighlighted = (ownGuess == Just True), guess = True }
            )
            cars


viewButton : Color.Color -> { isHighlighted : Bool, guess : Bool } -> Html Bool
viewButton color { isHighlighted, guess } =
    div
        [ style <|
            [ ( "display", "inline-block" )
            , ( "width", "45px" )
            , ( "height", "45px" )
            , ( "margin", "0 15px" )
            , ( "padding", "1px" )
            , ( "color", colorToString color )
            , ( "background-color", "currentColor" )
            , ( "border-radius", "50%" )
            , ( "border"
              , "2px solid "
                    ++ (if isHighlighted then
                            "currentColor"
                        else
                            "transparent"
                       )
              )
            ]
        , onClick guess
        ]
        []


type alias Shape =
    { nodes : List ( Float, Float, Float )
    , faces : List ( Int, Int, Int )
    }



-- Colors


light : Vec3
light =
    vec3 -0.3 0.2 1 |> Vector3.normalize


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


colorToString : Color.Color -> String
colorToString color =
    Color.toRgb color
        |> (\{ red, green, blue, alpha } -> "rgba(" ++ (toString red) ++ "," ++ (toString green) ++ "," ++ (toString blue) ++ "," ++ (toString alpha) ++ ")")


cyan : Color.Color
cyan =
    Color.rgb 39 171 178


lightGrey : Color.Color
lightGrey =
    Color.rgb 230 230 230


red : Color.Color
red =
    Color.rgb 229 41 56


black : Color.Color
black =
    Color.rgb 15 32 55


purple : Color.Color
purple =
    Color.rgb 78 60 127


brighten : Float -> Color.Color -> Color.Color
brighten fact =
    Color.toHsl
        >> (\{ hue, saturation, lightness } -> Color.hsl hue saturation (lightness * fact))



-- Terrain


moebiusMesh : WebGL.Mesh Vertex
moebiusMesh =
    let
        res =
            161

        radius =
            0.5

        width =
            0.25
    in
        List.repeat (res + 3) 0
            |> List.indexedMap
                (\i _ ->
                    let
                        angle =
                            2 * pi * (toFloat i) / (toFloat res)

                        isEven =
                            rem i 2 == 0

                        r =
                            if isEven then
                                radius - (width / 2) * (cos angle)
                            else
                                radius + (width / 2) * (cos angle)
                    in
                        Vertex
                            (vec3
                                ((cos angle) * r)
                                ((sin angle) * r)
                                ((width / 2)
                                    * (sin angle)
                                    * (if isEven then
                                        1
                                       else
                                        -1
                                      )
                                )
                            )
                            (vec3
                                (-(cos angle) * (sin angle))
                                (-(sin angle) * (sin angle))
                                (cos angle)
                            )
                            (colorToVec4 cyan)
                )
            |> WebGL.triangleStrip



-- Car


type alias TrianglesShape =
    List
        { normal : ( Float, Float, Float )
        , coordinates : ( ( Float, Float, Float ), ( Float, Float, Float ), ( Float, Float, Float ) )
        }


carTransform : Float -> Float -> Matrix4.Mat4
carTransform lateralPosition carAngle =
    let
        translateXY =
            Matrix4.makeTranslate (vec3 (0.5 * (cos carAngle)) (0.5 * (sin carAngle)) 0)

        translateZ =
            Matrix4.makeTranslate (vec3 0 0 0.025)

        translateY =
            Matrix4.makeTranslate
                (vec3
                    (-0.08 * lateralPosition * (carAngle + pi / 2 |> sin))
                    (0.08 * lateralPosition * (carAngle + pi / 2 |> cos))
                    0
                )

        rotateZ =
            Matrix4.makeRotate (carAngle + pi / 2) (vec3 0 0 1)

        rotateX =
            Matrix4.makeRotate (carAngle)
                (vec3
                    (cos (carAngle + pi / 2))
                    (sin (carAngle + pi / 2))
                    0
                )

        scale =
            Matrix4.makeScale (vec3 0.4 0.4 0.4)
    in
        [ translateXY, rotateX, translateY, translateZ, rotateZ, scale ]
            |> List.foldl (\current accumulator -> Matrix4.mul accumulator current) Matrix4.identity


carMesh : Color.Color -> WebGL.Mesh Vertex
carMesh color =
    let
        color_ =
            color |> colorToVec4
    in
        carShape
            |> List.map
                (\{ normal, coordinates } ->
                    let
                        ( normalX, normalY, normalZ ) =
                            normal

                        ( pt1, pt2, pt3 ) =
                            coordinates

                        ptToVec =
                            (\( x, y, z ) -> vec3 x y z)

                        normalVec =
                            vec3 normalX normalY normalZ
                    in
                        ( Vertex (ptToVec pt1) normalVec color_
                        , Vertex (ptToVec pt2) normalVec color_
                        , Vertex (ptToVec pt3) normalVec color_
                        )
                )
            |> WebGL.triangles


carShape : TrianglesShape
carShape =
    [ { normal = ( 0.0, 0.0, 1.0 )
      , coordinates =
            ( ( -0.11705460018119969, 0.0012516894548989877, 0.0 )
            , ( -0.07965401018148793, 0.0012516894548989877, 0.0 )
            , ( -0.07965401018148793, 0.03865227945461074, 0.0 )
            )
      }
    , { normal = ( 0.0, 0.0, 1.0 )
      , coordinates =
            ( ( -0.0861333829621007, -0.008509160743683328, 0.0 )
            , ( -0.11325880186348414, -0.008509160743683328, 0.0 )
            , ( -0.0861333829621007, -0.03563457964506676, 0.0 )
            )
      }
    , { normal = ( 0.0, 0.0, 1.0 )
      , coordinates =
            ( ( -0.12077234892450511, -0.01737789916226379, 0.0 )
            , ( -0.1407723489245051, -0.01737789916226379, 0.0 )
            , ( -0.12077234892450511, -0.037377899162263785, 0.0 )
            )
      }
    , { normal = ( 0.24253562503633297, 0.0, 0.9701425001453319 )
      , coordinates =
            ( ( 0.03, -0.05, 0.01 )
            , ( 0.07, -0.05, 0.0 )
            , ( 0.07, 0.05, 0.0 )
            )
      }
    , { normal = ( 0.0, 0.09950371902099892, 0.9950371902099892 )
      , coordinates =
            ( ( 0.07, 0.05, 0.0 )
            , ( 0.03, 0.05, 0.0 )
            , ( 0.03, -0.05, 0.01 )
            )
      }
    , { normal = ( -0.09759000729485331, 0.19518001458970663, 0.9759000729485331 )
      , coordinates =
            ( ( -0.07, -0.05, 0.0 )
            , ( 0.03, -0.05, 0.01 )
            , ( -0.02, 0.0, -0.005 )
            )
      }
    , { normal = ( 0.09950371902099892, 0.0, 0.9950371902099892 )
      , coordinates =
            ( ( -0.07, 0.05, 0.0 )
            , ( -0.07, -0.05, 0.0 )
            , ( -0.02, 0.0, -0.005 )
            )
      }
    , { normal = ( 0.0, -0.09950371902099892, 0.9950371902099892 )
      , coordinates =
            ( ( -0.07, 0.05, 0.0 )
            , ( -0.02, 0.0, -0.005 )
            , ( 0.03, 0.05, 0.0 )
            )
      }
    , { normal = ( -0.19518001458970663, 0.09759000729485331, 0.9759000729485331 )
      , coordinates =
            ( ( -0.02, 0.0, -0.005 )
            , ( 0.03, -0.05, 0.01 )
            , ( 0.03, 0.05, 0.0 )
            )
      }
    ]



-- Shaders


type alias Varyings =
    { vColor : Vec4
    }


type alias Uniforms =
    { transform : Matrix4.Mat4
    , perspective : Matrix4.Mat4
    }


vertexShader : WebGL.Shader Vertex Uniforms Varyings
vertexShader =
    [glsl|
attribute vec3 position;
attribute vec4 color;
attribute vec3 normal;
uniform mat4 perspective;
uniform mat4 transform;
varying vec4 vColor;
const vec3 lightDirection = vec3(0.0, 0.0, 1.0);
void main () {
  gl_Position = (perspective * transform) * vec4(position, 1.0);
  float brightness = 0.6 + dot(lightDirection, normalize(normal)) * 0.4;
  vColor = vec4(color.r * brightness, color.g * brightness, color.b * brightness, color.a);
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
