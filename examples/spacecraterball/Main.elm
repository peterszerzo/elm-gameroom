port module Main exposing (..)

import Json.Encode as JE
import Json.Decode as JD
import Time
import Window
import Color
import Random
import Html exposing (Html, div)
import Html.Attributes exposing (width, height, style)
import Html.Events exposing (onClick)
import Svg exposing (svg, path, use)
import Svg.Attributes exposing (viewBox, d)
import WebGL
import WebGL.Settings.Blend as Blend
import Math.Vector3 as Vector3 exposing (Vec3, vec3)
import Math.Vector4 as Vector4 exposing (Vec4, vec4)
import Math.Matrix4 as Matrix4
import Gameroom exposing (..)


-- Types


type alias Problem =
    { incomingAngle : Float
    , deviationFromCorrectPath : Float
    }


type alias Guess =
    Bool


type alias Vertex =
    { position : Vec3
    , normal : Vec3
    , color : Vec4
    }


type alias Uniforms =
    { perspective : Matrix4.Mat4
    , transform : Matrix4.Mat4
    }


type alias Varyings =
    { vColor : Vec4
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


port outgoing : JE.Value -> Cmd msg


port incoming : (JE.Value -> msg) -> Sub msg


main : Program Never (Model Problem Guess) (Msg Problem Guess)
main =
    gameWith
        [ basePath "/spacecraterball"
        , unicodeIcon "🚀"
        , name "Spacecraterball"
        , subheading "A futuristic physics game"
        , instructions "Will the rock land inside the crater or bounce off?"
        , clearWinner 100
        , responsiblePorts { incoming = incoming, outgoing = outgoing }
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
        , evaluate =
            (\problem guess ->
                if willStayInCrater problem then
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
        , problemDecoder = problemDecoder
        , problemEncoder = problemEncoder
        , guessDecoder = JD.bool
        , guessEncoder = JE.bool
        , problemGenerator = problemGenerator
        }



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
        [ (if guess then
            inIcon
           else
            outIcon
          )
            [ style
                [ ( "width", "100%" )
                , ( "height", "100%" )
                , ( "fill", "rgb(78, 60, 127)" )
                , ( "cursor", "pointer" )
                , ( "pointer-events", "none" )
                ]
            ]
        ]


inIcon : List (Html.Attribute msg) -> Html msg
inIcon attrs =
    svg
        ([ viewBox "0 0 200 200"
         ]
            ++ attrs
        )
        [ path
            [ d "M100,200 C44.771525,200 0,155.228475 0,100 C0,44.771525 44.771525,0 100,0 C155.228475,0 200,44.771525 200,100 C200,155.228475 155.228475,200 100,200 Z M25.5952381,139.285714 L81.6393625,139.285714 C83.611808,139.285714 85.210791,137.686731 85.210791,135.714286 C85.210791,133.74184 83.611808,132.142857 81.6393625,132.142857 L25.5952381,132.142857 C23.6227926,132.142857 22.0238095,133.74184 22.0238095,135.714286 C22.0238095,137.686731 23.6227926,139.285714 25.5952381,139.285714 Z M119.642857,139.285714 L175.686982,139.285714 C177.659427,139.285714 179.25841,137.686731 179.25841,135.714286 C179.25841,133.74184 177.659427,132.142857 175.686982,132.142857 L119.642857,132.142857 C117.670412,132.142857 116.071429,133.74184 116.071429,135.714286 C116.071429,137.686731 117.670412,139.285714 119.642857,139.285714 Z M49.4047619,73.8095238 C55.6508394,73.8095238 60.7142857,68.7460775 60.7142857,62.5 C60.7142857,56.2539225 55.6508394,51.1904762 49.4047619,51.1904762 C43.1586844,51.1904762 38.0952381,56.2539225 38.0952381,62.5 C38.0952381,68.7460775 43.1586844,73.8095238 49.4047619,73.8095238 Z M64.6274768,76.4267545 C64.6940341,76.4750451 64.8426615,76.5878752 65.067665,76.7667728 C65.4554128,77.0750663 65.9081739,77.4524987 66.4202607,77.9005985 C67.8984021,79.1940415 69.5457325,80.7885885 71.3168387,82.6965066 C71.9878069,83.4193047 73.1176777,83.4613212 73.8404758,82.790353 C74.5632739,82.1193849 74.6052904,80.9895141 73.9343222,80.266716 C72.0778664,78.2668554 70.3418269,76.5864416 68.7721341,75.212887 C67.8162234,74.3764203 67.1185164,73.821682 66.7248297,73.5360431 C65.9265818,72.9568751 64.8099656,73.1344744 64.2307975,73.9327223 C63.6516295,74.7309703 63.8292289,75.8475865 64.6274768,76.4267545 Z M77.3044838,89.8680485 C79.1149901,92.2650327 80.8913103,94.8361688 82.618643,97.585554 C83.1432972,98.4206429 84.2455867,98.6722999 85.0806755,98.1476458 C85.9157644,97.6229917 86.1674214,96.5207022 85.6427673,95.6856134 C83.8605678,92.848897 82.0260575,90.1935337 80.1543236,87.7154884 C79.5599105,86.9285268 78.4400852,86.7724355 77.6531236,87.3668486 C76.8661621,87.9612616 76.7100708,89.081087 77.3044838,89.8680485 Z M87.3003052,105.731301 C88.7232423,108.441074 90.0808326,111.264048 91.3665763,114.202064 C91.7619663,115.105558 92.8149202,115.517458 93.7184145,115.122068 C94.6219089,114.726678 95.0338088,113.673724 94.6384187,112.77023 C93.3186625,109.754493 91.9244148,106.855293 90.4622934,104.070899 C90.0037863,103.19774 88.9242576,102.861599 88.0510987,103.320106 C87.1779397,103.778613 86.841798,104.858142 87.3003052,105.731301 Z M94.8459184,122.93275 C95.8926946,125.829462 96.8686569,128.812183 97.7700074,131.881997 C98.0478503,132.828274 99.040195,133.370146 99.9864712,133.092303 C100.932747,132.81446 101.47462,131.822115 101.196777,130.875839 C100.274892,127.736088 99.2762745,124.68413 98.2047649,121.718974 C97.8695899,120.791454 96.8459734,120.311263 95.9184536,120.646439 C94.9909337,120.981614 94.5107434,122.00523 94.8459184,122.93275 Z M100.165388,141.005781 C100.865591,144.01534 101.496278,147.094201 102.054956,150.243075 C102.227243,151.214132 103.154106,151.861664 104.125164,151.689377 C105.096221,151.517091 105.743753,150.590227 105.571466,149.61917 C105.001774,146.408221 104.358424,143.267536 103.64391,140.196469 C103.420425,139.235901 102.46056,138.638378 101.499993,138.861864 C100.539426,139.085349 99.9419026,140.045213 100.165388,141.005781 Z M103.472791,159.587323 C103.748971,161.764644 103.992114,163.971023 104.201595,166.20664 C104.293602,167.188562 105.164194,167.90998 106.146115,167.817972 C107.128037,167.725965 107.849455,166.855373 107.757447,165.873452 C107.544335,163.599076 107.296921,161.353949 107.01583,159.13791 C106.891728,158.159527 105.997987,157.466995 105.019604,157.591097 C104.04122,157.715199 103.348689,158.60894 103.472791,159.587323 Z"
            ]
            []
        ]


outIcon : List (Html.Attribute msg) -> Html msg
outIcon attrs =
    svg
        ([ viewBox "0 0 200 200"
         ]
            ++ attrs
        )
        [ path
            [ d "M79.5495543,125.971031 C79.7423662,126.216208 80.0019282,126.414011 80.3144394,126.533542 C81.2355812,126.885868 82.2679303,126.424751 82.6202557,125.503609 C83.6205506,122.888375 84.8488087,120.499709 86.2895234,118.326267 C86.8344202,117.504244 86.6097646,116.396136 85.7877409,115.851239 C84.9657173,115.306342 83.8576094,115.530998 83.3127126,116.353022 C82.3496591,117.805871 81.4741286,119.343598 80.6900174,120.967768 C79.5860873,118.982689 78.3806824,117.076759 77.0798066,115.248591 C76.5080203,114.445039 75.3930884,114.257156 74.5895364,114.828942 C73.7859844,115.400728 73.5981011,116.51566 74.1698874,117.319212 C75.9415117,119.80894 77.5246642,122.451145 78.9028963,125.250813 C79.0537037,125.557155 79.2806054,125.801089 79.5495543,125.971031 Z M100,200 C44.771525,200 0,155.228475 0,100 C0,44.771525 44.771525,0 100,0 C155.228475,0 200,44.771525 200,100 C200,155.228475 155.228475,200 100,200 Z M25.5952381,139.285714 L81.6393625,139.285714 C83.611808,139.285714 85.210791,137.686731 85.210791,135.714286 C85.210791,133.74184 83.611808,132.142857 81.6393625,132.142857 L25.5952381,132.142857 C23.6227926,132.142857 22.0238095,133.74184 22.0238095,135.714286 C22.0238095,137.686731 23.6227926,139.285714 25.5952381,139.285714 Z M119.642857,139.285714 L175.686982,139.285714 C177.659427,139.285714 179.25841,137.686731 179.25841,135.714286 C179.25841,133.74184 177.659427,132.142857 175.686982,132.142857 L119.642857,132.142857 C117.670412,132.142857 116.071429,133.74184 116.071429,135.714286 C116.071429,137.686731 117.670412,139.285714 119.642857,139.285714 Z M27.9761905,97.6190476 C34.222268,97.6190476 39.2857143,92.5556013 39.2857143,86.3095238 C39.2857143,80.0634463 34.222268,75 27.9761905,75 C21.7301129,75 16.6666667,80.0634463 16.6666667,86.3095238 C16.6666667,92.5556013 21.7301129,97.6190476 27.9761905,97.6190476 Z M126.033209,101.943298 C126.129502,101.943298 126.339686,101.948125 126.653802,101.963175 C127.192817,101.989 127.816124,102.035809 128.513746,102.108949 C130.520549,102.319348 132.707181,102.698961 134.993777,103.289629 C135.948656,103.536291 136.922697,102.962168 137.169359,102.007289 C137.416021,101.05241 136.841898,100.078369 135.887019,99.8317074 C133.420944,99.1946766 131.06145,98.7850543 128.886143,98.5569891 C127.566875,98.4186735 126.589987,98.3718695 126.033209,98.3718695 C125.046986,98.3718695 124.247495,99.171361 124.247495,100.157584 C124.247495,101.143807 125.046986,101.943298 126.033209,101.943298 Z M143.549944,106.481925 C146.278983,107.857629 148.810177,109.53036 151.09806,111.525255 C151.841395,112.173397 152.96941,112.096229 153.617553,111.352894 C154.265695,110.609559 154.188527,109.481544 153.445192,108.833401 C150.924827,106.635797 148.144884,104.798681 145.157584,103.292787 C144.276928,102.84885 143.203133,103.20288 142.759195,104.083536 C142.315258,104.964192 142.669288,106.037987 143.549944,106.481925 Z M157.055901,118.326267 C158.496615,120.499709 159.724874,122.888375 160.725168,125.503609 C161.077494,126.424751 162.109843,126.885868 163.030985,126.533542 C163.952126,126.181217 164.413243,125.148868 164.060918,124.227726 C162.967112,121.368011 161.618577,118.745436 160.032712,116.353022 C159.487815,115.530998 158.379707,115.306342 157.557683,115.851239 C156.73566,116.396136 156.511004,117.504244 157.055901,118.326267 Z M117.312215,98.3718695 C116.755437,98.3718695 115.77855,98.4186735 114.459281,98.5569891 C112.283974,98.7850543 109.924481,99.1946766 107.458405,99.8317074 C106.503526,100.078369 105.929403,101.05241 106.176065,102.007289 C106.422727,102.962168 107.396768,103.536291 108.351647,103.289629 C110.638243,102.698961 112.824875,102.319348 114.831678,102.108949 C115.5293,102.035809 116.152607,101.989 116.691622,101.963175 C117.005739,101.948125 117.215922,101.943298 117.312215,101.943298 C118.298438,101.943298 119.09793,101.143807 119.09793,100.157584 C119.09793,99.171361 118.298438,98.3718695 117.312215,98.3718695 Z M98.1878404,103.292787 C95.2005398,104.798681 92.4205971,106.635797 89.9002323,108.833401 C89.1568975,109.481544 89.079729,110.609559 89.7278715,111.352894 C90.3760141,112.096229 91.5040293,112.173397 92.2473641,111.525255 C94.535247,109.53036 97.0664414,107.857629 99.7954797,106.481925 C100.676136,106.037987 101.030166,104.964192 100.586229,104.083536 C100.142291,103.20288 99.0684964,102.84885 98.1878404,103.292787 Z M45.1556217,95.2609362 C45.2448549,95.2888075 45.4379769,95.3533971 45.7266662,95.4568392 C46.2211348,95.6340155 46.7946606,95.8543418 47.4389227,96.1199328 C49.2934944,96.8844624 51.3321782,97.8556361 53.4885196,99.0500662 C54.3512335,99.5279365 55.4379917,99.215959 55.915862,98.3532451 C56.3937323,97.4905311 56.0817549,96.4037729 55.2190409,95.9259026 C52.9388029,94.6628443 50.7771279,93.633081 48.8000868,92.8180644 C47.6003753,92.3234947 46.7184958,92.0075028 46.2204014,91.8519266 C45.2790294,91.5578958 44.2775375,92.0826695 43.9835067,93.0240415 C43.689476,93.9654135 44.2142497,94.9669054 45.1556217,95.2609362 Z M61.2562958,104.102972 C63.7001857,105.951765 66.029757,107.985965 68.213508,110.213434 C68.9039275,110.917676 70.0345237,110.928881 70.7387653,110.238461 C71.4430069,109.548042 71.4542119,108.417446 70.7637923,107.713204 C68.4537162,105.356881 65.9918172,103.207131 63.4109762,101.254735 C62.6244572,100.659736 61.504516,100.814994 60.9095175,101.601513 C60.3145189,102.388032 60.4697769,103.507973 61.2562958,104.102972 Z"
            ]
            []
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
