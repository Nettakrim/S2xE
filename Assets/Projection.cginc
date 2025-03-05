sampler2D _MapColor;
float _MapScale;

float3 _MapBackground;

sampler2D _MapHeight;
float _HeightScale;

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

inline float2 GetUV(float3 nPos) {
    return nPos.xz*rsqrt(1+nPos.y)*_MapScale/2 + float2(0.5, 0.5);
}

inline float GetHeightFromMapValue(float value) {
    float c = max((value-0.22), 0);
    return exp(c * _HeightScale);
}

float3 GetTextureAtPos(float3 nPos) {
    float2 uv = GetUV(nPos);

    if (uv.x >= 0 && uv.y >= 0 && uv.x <= 1 && uv.y <= 1 && nPos.y > -0.9) {
        return tex2D(_MapColor, uv).rgb;
    } else {
        return _MapBackground;
    }
}

float GetHeightAtPos(float3 nPos) {
    float2 uv = GetUV(nPos);

    if (uv.x >= 0 && uv.y >= 0 && uv.x <= 1 && uv.y <= 1 && nPos.y > -0.9) {
        return GetHeightFromMapValue(tex2Dlod(_MapHeight, float4(uv,0,0)).r);
    } else {
        return 1;
    }
}