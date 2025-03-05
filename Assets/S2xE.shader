Shader "Custom/S2xE"
{
    Properties
    {
        _MapColor("MapColor", 2D) = "white" {}
        _MapScale("MapScale", Float) = 1
        _MapBackground("MapBackground", Color) = (1,1,1,1)
        _SkyColor("SkyColor", Color) = (0.5,0.5,1,1)
        _RayMarchSteps("Ray March Steps", Float) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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


            sampler2D _MapColor;
            float _MapScale;

            fixed3 _MapBackground;
            fixed3 _SkyColor;

            int _RayMarchSteps;

            float3x3 RotationAroundAxis(float3 Axis, float Rotation)
            {
                float s = sin(Rotation);
                float c = cos(Rotation);
                float one_minus_c = 1.0 - c;
                Axis = normalize(Axis);

                return float3x3(
                    one_minus_c * Axis.x * Axis.x + c, one_minus_c * Axis.x * Axis.y - Axis.z * s, one_minus_c * Axis.z * Axis.x + Axis.y * s,
                    one_minus_c * Axis.x * Axis.y + Axis.z * s, one_minus_c * Axis.y * Axis.y + c, one_minus_c * Axis.y * Axis.z - Axis.x * s,
                    one_minus_c * Axis.z * Axis.x - Axis.y * s, one_minus_c * Axis.y * Axis.z + Axis.x * s, one_minus_c * Axis.z * Axis.z + c
                );
            }

            inline float3 GetAxis(float3 pos, float3 view) {
                // get axis that given view ray at position will be rotating around
                // this is actually just the cross product
                return cross(pos, view);
            }


            float GetHeightAtPos(float3 nPos) {
                return 1;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float3 pos = _WorldSpaceCameraPos.xyz;
                float3 axis = GetAxis(_WorldSpaceCameraPos.xyz, i.viewDir);

                float height = length(pos);
                float3 nPos = pos/height;

                float eSlope = dot(nPos, i.viewDir);
                float sSlope = length(i.viewDir - nPos*eSlope);

                bool hit = false;
                for (int i = 0; i < _RayMarchSteps; i++) {
                    //do proper SDF - generate a texture from the height map? thats like "rounded out" is this possible?
                    float maxStep = (height-1) / -eSlope;

                    if (maxStep < 0) {
                        break;
                    }

                    pos = mul(RotationAroundAxis(axis, maxStep * sSlope), pos + (nPos*eSlope*maxStep));

                    height = length(pos);
                    nPos = pos/height;
                    if (height <= GetHeightAtPos(pos)) {
                        hit = true;
                        break;
                    }
                }

                float3 col = float3(0,0,0);
                if (hit) {
                    float2 uv = nPos.xz*rsqrt(1+nPos.y)*_MapScale/2 + float2(0.5, 0.5);
                    
                    if (uv.x >= 0 && uv.y >= 0 && uv.x <= 1 && uv.y <= 1 && nPos.y > -0.9) {
                        col = tex2D(_MapColor, uv).rgb;
                    } else {
                        col = _MapBackground;
                    }
                } else {
                    col = _SkyColor;
                }

                return fixed4(col.r, col.g, col.b, 1);
            }
            ENDCG
        }
    }
}
