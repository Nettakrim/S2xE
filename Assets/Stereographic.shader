Shader "Custom/Stereographic"
{
    Properties
    {
        _MapColor("MapColor", 2D) = "white" {}
        _MapScale("MapScale", Float) = 1
        _MapBackground("MapBackground", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/Projection.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 pos : COLOR;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.pos = v.normal;
                return o;
            }


            sampler2D _MapColor;
            float _MapScale;

            fixed3 _MapBackground;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = GetUV(i.pos, _MapScale);
                   
                float3 col;
                if (uv.x >= 0 && uv.y >= 0 && uv.x <= 1 && uv.y <= 1 && i.pos.y > -0.9) {
                    col = tex2D(_MapColor, uv).rgb;
                } else {
                    col = _MapBackground;
                };

                return fixed4(col.r, col.g, col.b, 1);
            }
            ENDCG
        }
    }
}
