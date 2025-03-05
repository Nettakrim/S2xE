Shader "Custom/S2xE"
{
    Properties
    {
        _MapColor("MapColor", 2D) = "white" {}
        _MapScale("MapScale", Float) = 1
        _MapBackground("MapBackground", Color) = (1,1,1,1)
        _SkyColor("SkyColor", Color) = (0.5,0.5,1,1)
        _MapHeight("MapHeight", 2D) = "gray" {}
        _HeightScale("HeightScale", Float) = 1
        _RayMarchSteps("Ray March Steps", Float) = 1
        _MipLevels("Mip Levels", Float) = 7
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

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewDir = mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos.xyz;
                return o;
            }

            fixed3 _SkyColor;

            int _RayMarchSteps;

            int _MipLevels;

            fixed4 frag (v2f i) : SV_Target
            {

                float3 pos = _WorldSpaceCameraPos.xyz;
                float3 axis = cross(_WorldSpaceCameraPos.xyz, i.viewDir);

                float height = length(pos);
                float3 nPos = pos/height;

                float eSlope = dot(nPos, i.viewDir);
                float sSlope = length(i.viewDir - nPos*eSlope);

                bool hit = false;
                [loop]
                for (int i = 0; i < _RayMarchSteps; i++) {
                    float2 uv = GetUV(nPos);

                    int mipHit = _MipLevels+1;
                    for (int mip = 0; mip <= _MipLevels; mip++) {
                        if (height <= GetHeightAtPos(nPos, uv, mip)) {
                            mipHit = mip;
                            break;
                        }
                    }
                    
                    if (mipHit == 0) {
                        hit = true;
                        break;
                    }
                    
                    // TODO: go to next mip border

                    //float maxStep = (height-1) / -eSlope;
                    float maxStep = 0.002*mipHit;

                    //if (maxStep < 0) {
                    //    break;
                    //}

                    pos = mul(RotationAroundAxis(axis, maxStep * sSlope), pos + (nPos*eSlope*maxStep));

                    height = length(pos);
                    nPos = pos/height;
                }

                float3 col;
                if (hit) {
                    col = GetTextureAtPos(nPos, GetUV(nPos));
                } else {
                    col = _SkyColor;
                }

                return fixed4(col.r, col.g, col.b, 1);
            }
            ENDCG
        }
    }
}
