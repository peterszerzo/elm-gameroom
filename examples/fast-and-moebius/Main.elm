port module Main exposing (..)

import Time
import Random
import Color
import Window
import Json.Encode as JE
import Json.Decode as JD
import Html exposing (Html, div)
import Html.Attributes exposing (width, height, style)
import Html.Events exposing (onClick)
import Math.Vector3 as Vector3 exposing (Vec3, vec3)
import Math.Vector4 as Vector4 exposing (Vec4, vec4)
import Math.Matrix4 as Matrix4
import WebGL
import Gameroom exposing (..)


-- Problem


type alias Problem =
    List Car


problemEncoder : Problem -> JE.Value
problemEncoder problem =
    List.map carEncoder problem |> JE.list


problemDecoder : JD.Decoder Problem
problemDecoder =
    JD.list carDecoder


problemGenerator : Random.Generator Problem
problemGenerator =
    Random.list 4 carGenerator



-- Guess


type alias Guess =
    Int


guessEncoder : Guess -> JE.Value
guessEncoder =
    JE.int


guessDecoder : JD.Decoder Guess
guessDecoder =
    JD.int



-- Car


type alias Car =
    { acceleration : Float
    , maxSpeed : Float
    , engineBlowsAt : Maybe Float
    }


carEncoder : Car -> JE.Value
carEncoder car =
    JE.object
        [ ( "acceleration", JE.float car.acceleration )
        , ( "maxSpeed", JE.float car.acceleration )
        , ( "engineBlowsAt", car.engineBlowsAt |> Maybe.map JE.float |> Maybe.withDefault JE.null )
        ]


carDecoder : JD.Decoder Car
carDecoder =
    JD.map3 Car
        (JD.field "acceleration" JD.float)
        (JD.field "maxSpeed" JD.float)
        (JD.field "engineBlowsAt" (JD.nullable JD.float))


carGenerator : Random.Generator Car
carGenerator =
    Random.map3 Car
        (Random.float 0.375 0.75)
        (Random.float 1.5 3)
        (Random.map2
            (\engineBlowsAt blowProbabilityFactor ->
                if blowProbabilityFactor > 0.8 then
                    Just engineBlowsAt
                else
                    Nothing
            )
            (Random.float 0.6 0.9)
            (Random.float 0 1)
        )


carTime : Car -> Maybe Time.Time
carTime car =
    let
        maxSpeedTime =
            car.maxSpeed / car.acceleration

        maxSpeedDistance =
            car.acceleration * (maxSpeedTime ^ 2) / 2
    in
        case car.engineBlowsAt of
            Just _ ->
                Nothing

            Nothing ->
                (if maxSpeedDistance > 1 then
                    sqrt <| 2 / car.acceleration
                 else
                    (1 - maxSpeedDistance) / car.maxSpeed
                )
                    |> (*) 5000
                    |> Just


carPosition : Time.Time -> Car -> Float
carPosition rawTime car =
    let
        time =
            rawTime / 5000

        maxSpeedTime =
            car.maxSpeed / car.acceleration

        maxSpeedDistance =
            car.acceleration * (maxSpeedTime ^ 2) / 2

        idealDistance =
            if (time < maxSpeedTime) then
                car.acceleration * (time ^ 2) / 2
            else
                maxSpeedDistance + car.maxSpeed * (time - maxSpeedTime)
    in
        min (Maybe.withDefault 1 car.engineBlowsAt) idealDistance


carColor : Int -> Color.Color
carColor index =
    case index of
        0 ->
            red

        1 ->
            lightGrey

        2 ->
            black

        3 ->
            purple

        _ ->
            purple



-- Raw shape


type alias Shape =
    { nodes : List ( Float, Float, Float )
    , faces : List ( Int, Int, Int )
    }



-- WebGL types


type alias Vertex =
    { position : Vec3
    , normal : Vec3
    , color : Vec4
    }


type alias Varyings =
    { vColor : Vec4
    }


type alias Uniforms =
    { transform : Matrix4.Mat4
    , perspective : Matrix4.Mat4
    }



-- Ports


port outgoing : JE.Value -> Cmd msg


port incoming : (JE.Value -> msg) -> Sub msg


main : Program Never (Model Problem Guess) (Msg Problem Guess)
main =
    gameWith
        [ basePath "/fast-and-moebius"
        , unicodeIcon "🏎️"
        , name "Fast and Moebius"
        , subheading "Engines and linear algebra!"
        , instructions "Which car is the winner?"
        , roundDuration (10 * Time.second)
        , responsiblePorts { outgoing = outgoing, incoming = incoming }
        ]
        { view =
            (\context problem ->
                let
                    perspective_ =
                        perspective context.roundTime
                in
                    div []
                        [ div
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
                                (\index ->
                                    viewButton (carColor index)
                                        { isHighlighted = (context.ownGuess == Just index)
                                        , guess =
                                            case context.ownGuess of
                                                Just guess ->
                                                    Nothing

                                                Nothing ->
                                                    Just index
                                        }
                                )
                                [ 0, 1, 2, 3 ]
                        , viewWebglContainer context.windowSize <|
                            [ WebGL.entity
                                vertexShader
                                fragmentShader
                                moebiusMesh
                                { perspective = perspective_
                                , transform = Matrix4.identity
                                }
                            , WebGL.entity
                                vertexShader
                                fragmentShader
                                (finishLineMesh context.roundTime)
                                { perspective = perspective_
                                , transform = Matrix4.identity
                                }
                            ]
                                ++ (List.indexedMap
                                        (\index car ->
                                            let
                                                carAngle =
                                                    carPosition context.roundTime car |> (*) (2 * pi)

                                                color =
                                                    carColor index
                                            in
                                                WebGL.entity
                                                    vertexShader
                                                    fragmentShader
                                                    (carMesh color)
                                                    { perspective = perspective_
                                                    , transform = carTransform (((toFloat index) - 1.5) / 1.5 * 0.66) carAngle
                                                    }
                                        )
                                        problem
                                   )
                        ]
            )
        , evaluate =
            (\problem guess ->
                List.drop guess problem
                    |> List.head
                    |> Maybe.andThen carTime
                    |> Maybe.map (\time -> 15000 - time)
                    |> Maybe.withDefault 0
            )
        , problemDecoder = problemDecoder
        , problemEncoder = problemEncoder
        , guessDecoder = guessDecoder
        , guessEncoder = guessEncoder
        , problemGenerator = problemGenerator
        }



-- Views


perspective : Float -> Matrix4.Mat4
perspective time =
    let
        theta =
            (sin (time / 800 / 16)) * pi / 6

        phi =
            pi / 8

        eye =
            vec3
                (sin theta * cos phi)
                (cos theta * cos phi)
                (sin phi)
                |> Vector3.scale
                    (2
                        - ((time / 35000) |> clamp 0 0.2)
                    )
    in
        Matrix4.mul (Matrix4.makePerspective 45 1 0.01 100)
            (Matrix4.makeLookAt eye (vec3 0 0 0) (vec3 0 0 1))


viewWebglContainer : Window.Size -> List WebGL.Entity -> Html Guess
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


viewButton : Color.Color -> { isHighlighted : Bool, guess : Maybe Guess } -> Html Guess
viewButton color { isHighlighted, guess } =
    div
        ([ style <|
            [ ( "display", "inline-block" )
            , ( "width", "45px" )
            , ( "height", "45px" )
            , ( "margin", "0 15px" )
            , ( "padding", "1px" )
            , ( "color", colorToString color )
            , ( "background-color", "currentColor" )
            , ( "border-radius", "50%" )
            , ( "outline"
              , "2px solid "
                    ++ (if isHighlighted then
                            "currentColor"
                        else
                            "transparent"
                       )
              )
            ]
         ]
            ++ (guess |> Maybe.map (\g -> [ onClick g ]) |> Maybe.withDefault [])
        )
        []



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
        |> (\{ red, green, blue, alpha } ->
                "rgba(" ++ (toString red) ++ "," ++ (toString green) ++ "," ++ (toString blue) ++ "," ++ (toString alpha) ++ ")"
           )


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


moebiusRadius : Float
moebiusRadius =
    0.5


moebiusWidth : Float
moebiusWidth =
    0.25


moebiusTransform : Float -> Float -> Float -> Matrix4.Mat4
moebiusTransform angle lateralOffset normalOffset =
    let
        sinAngle =
            sin angle

        cosAngle =
            cos angle

        translateXY =
            Matrix4.makeTranslate (vec3 (moebiusRadius * cosAngle) (moebiusRadius * sinAngle) 0)

        translateZ =
            Matrix4.makeTranslate (vec3 0 0 normalOffset)

        translateY =
            Matrix4.makeTranslate
                (vec3
                    (-0.5 * moebiusWidth * lateralOffset * cosAngle)
                    (-0.5 * moebiusWidth * lateralOffset * sinAngle)
                    0
                )

        rotateZ =
            Matrix4.makeRotate (angle + pi / 2) (vec3 0 0 1)

        rotateX =
            Matrix4.makeRotate angle
                (vec3
                    -sinAngle
                    cosAngle
                    0
                )
    in
        [ translateXY, rotateX, translateY, translateZ, rotateZ ]
            |> List.foldl (\current accumulator -> Matrix4.mul accumulator current) Matrix4.identity


finishLineMesh : Time.Time -> WebGL.Mesh Vertex
finishLineMesh time =
    let
        origin =
            (vec3 0 0 0)

        sinTime =
            sin (time / 1000)

        a =
            0.05 + 0.02 * sinTime

        b =
            0

        h =
            0.01

        pt1 =
            Matrix4.transform (moebiusTransform 0 -(1 + b) h) origin

        pt2 =
            Matrix4.transform (moebiusTransform a -(1 + b) h) origin

        pt3 =
            Matrix4.transform (moebiusTransform a (1 + b) h) origin

        pt4 =
            Matrix4.transform (moebiusTransform 0 (1 + b) h) origin

        normal =
            vec3 0 0 1

        color_ =
            colorToVec4 lightGrey
    in
        [ ( Vertex pt1 normal color_
          , Vertex pt2 normal color_
          , Vertex pt3 normal color_
          )
        , ( Vertex pt3 normal color_
          , Vertex pt4 normal color_
          , Vertex pt1 normal color_
          )
        ]
            |> WebGL.triangles


moebiusMesh : WebGL.Mesh Vertex
moebiusMesh =
    let
        res =
            101
    in
        List.repeat (res + 3) 0
            |> List.indexedMap
                (\i _ ->
                    let
                        angle =
                            2 * pi * (toFloat i) / (toFloat res)

                        lateralOffset =
                            if rem i 2 == 0 then
                                -1
                            else
                                1

                        transform =
                            (moebiusTransform angle lateralOffset 0)

                        pt =
                            Matrix4.transform transform (vec3 0 0 0)

                        normal =
                            Matrix4.transform transform (vec3 0 0 1)
                    in
                        Vertex
                            pt
                            normal
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
    Matrix4.mul (moebiusTransform carAngle lateralPosition 0.025)
        (Matrix4.makeScale (vec3 0.4 0.4 0.4))


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
  float brightness = 0.68 + dot(lightDirection, normalize(normal)) * 0.32;
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
