Shader "Custom/scrolling texture"
{
    Properties
    {
        _MapTex ("Map Texture", 2D) = "white" {}
        _GroundTex ("Ground Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}

        _Tiling ("Tiling", Vector) = (1, 1, 0, 0)
        _Offset ("Offset", Vector) = (0, 0, 0, 0)

        _ScrollX ("Scroll X", Float) = 1
        _ScrollY ("Scroll Y", Float) = 1
        _Frequency ("Frequency", Float) = 0.8
        _Speed ("Speed", Float) = 20
        _Amplitude ("Amplitude", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MapTex;
            sampler2D _GroundTex;
            sampler2D _NormalMap;

            float4 _Tiling;
            float4 _Offset;

            float _ScrollX;
            float _ScrollY;
            float _Frequency;
            float _Speed;
            float _Amplitude;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // Apply tiling and offset to UV
                o.uv = v.uv * _Tiling.xy + _Offset.xy;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Scrolling UVs for water texture
                float time = _Time.y * _Speed;
                float2 scrollUV = i.uv + float2(_ScrollX * time, _ScrollY * time);

                // Sampling textures
                fixed4 mapColor = tex2D(_MapTex, scrollUV);
                fixed4 groundColor = tex2D(_GroundTex, scrollUV);

                // Waves effect using sine function
                float wave = sin(i.uv.y * _Frequency + time) * _Amplitude;

                // Adding normal map effect
                fixed3 normalTex = UnpackNormal(tex2D(_NormalMap, i.uv + wave));
                
                // Final color output with water and foam blended
                fixed4 finalColor = mapColor * (1 - groundColor.a) + mapColor * groundColor.a;
                finalColor.rgb += wave; // Apply wave to color
                
                // Apply normal map to simulate bumpiness
                finalColor.rgb += normalTex * 0.2;

                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

   