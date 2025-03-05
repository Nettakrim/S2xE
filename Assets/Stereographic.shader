Shader "Custom/Stereographic"
{
    Properties
    {
        _MapColor("MapColor", 2D) = "white" {}
        _MapScale("MapScale", Float) = 1
        _MapBackground("MapBackground", Color) = (1,1,1,1)
        _MapHeight("MapHeight", 2D) = "gray" {}
        _HeightScale("HeightScale", Float) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

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
                o.pos = v.normal;
                o.vertex = UnityObjectToClipPos(v.vertex * GetHeightAtPos(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(GetTextureAtPos(i.pos), 1);
            }
            ENDCG
        }
    }
}
