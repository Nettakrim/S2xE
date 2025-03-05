inline float2 GetUV(float3 nPos, float mapScale) {
    return nPos.xz*rsqrt(1+nPos.y)*mapScale/2 + float2(0.5, 0.5);
}
